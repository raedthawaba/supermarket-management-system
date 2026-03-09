from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from math import radians, cos, sin, asin, sqrt

from app.database.session import get_db
from app.modules.users.models import User, DeliveryProfile
from app.modules.orders.models import Order, OrderStatus
from app.modules.delivery.models import Delivery
from app.core.security import get_current_user

router = APIRouter()


# Helper function for distance calculation
def calculate_distance(lat1, lon1, lat2, lon2):
    """حساب المسافة بين نقطتين بالكيلومتر"""
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    return c * 6371


# Pydantic Schemas
class DeliverySchema(BaseModel):
    id: int
    order_id: int
    delivery_agent_id: Optional[int] = None
    delivery_type: str
    status: str
    distance_km: Optional[float] = None
    delivery_fee: float
    driver_earning: float

    class Config:
        from_attributes = True


class DeliveryStatusUpdate(BaseModel):
    status: str


@router.get("/available")
async def get(
    lat: float,
    long: float,
    radius: float = Query(default=10, ge=1, le=50),
    limit:_available_deliveries int = Query(default=20, ge=1, le=50),
    db: AsyncSession = Depends(get_db)
):
    """الحصول على الطلبات المتاحة للتوصيل"""

    # الحصول على الطلبات الجاهزة للتسليم
    result = await db.execute(
        select(Order).where(
            and_(
                Order.status == OrderStatus.READY_FOR_PICKUP.value
            )
        )
    )
    orders = result.scalars().all()

    available_orders = []
    for order in orders:
        if order.address and order.address.lat:
            distance = calculate_distance(
                lat, long,
                order.address.lat, order.address.long
            )
            if distance <= radius:
                available_orders.append({
                    "order_id": order.id,
                    "order_number": order.order_number,
                    "store_name": order.store.name,
                    "pickup_address": order.store.address,
                    "delivery_address": order.address.address,
                    "distance_km": round(distance, 2),
                    "delivery_fee": order.delivery_fee,
                    "total": order.total
                })

    return available_orders


@router.post("/{order_id}/accept")
async def accept_delivery(
    order_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """قبول طلب توصيل"""

    if current_user.role != "delivery_agent":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="فقط المندوبين يمكنهم قبول طلبات التوصيل"
        )

    # التحقق من حالة الطلب
    result = await db.execute(
        select(Order).where(Order.id == order_id)
    )
    order = result.scalar_one_or_none()

    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="الطلب غير موجود"
        )

    if order.status != OrderStatus.READY_FOR_PICKUP.value:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="الطلب غير متاح للتوصيل"
        )

    # إنشاء سجل التوصيل
    delivery = Delivery(
        order_id=order_id,
        delivery_agent_id=current_user.id,
        delivery_type="platform",
        status="accepted",
        delivery_fee=order.delivery_fee,
        driver_earning=order.delivery_fee * 0.80,  # 80% للمندوب
        accepted_at=datetime.utcnow()
    )

    db.add(delivery)

    # تحديث حالة الطلب
    order.status = OrderStatus.OUT_FOR_DELIVERY.value

    await db.commit()

    return {"message": "تم قبول طلب التوصيل بنجاح", "delivery_id": delivery.id}


@router.put("/{order_id}/status")
async def update_delivery_status(
    order_id: int,
    status_data: DeliveryStatusUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """تحديث حالة التوصيل"""

    if current_user.role != "delivery_agent":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="فقط المندوبين يمكنهم تحديث حالة التوصيل"
        )

    # الحصول على سجل التوصيل
    result = await db.execute(
        select(Delivery).where(
            and_(
                Delivery.order_id == order_id,
                Delivery.delivery_agent_id == current_user.id
            )
        )
    )
    delivery = result.scalar_one_or_none()

    if not delivery:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="سجل التوصيل غير موجود"
        )

    # تحديث الحالة
    delivery.status = status_data.status
    now = datetime.utcnow()

    if status_data.status == "picked_up":
        delivery.picked_up_at = now
    elif status_data.status == "delivered":
        delivery.delivered_at = now

    # تحديث حالة الطلب
    order_result = await db.execute(
        select(Order).where(Order.id == order_id)
    )
    order = order_result.scalar_one_or_none()

    if order:
        if status_data.status == "delivered":
            order.status = OrderStatus.DELIVERED.value

            # إضافة الأرباح لمحفظة المندوب
            driver_profile_result = await db.execute(
                select(DeliveryProfile).where(
                    DeliveryProfile.user_id == current_user.id
                )
            )
            driver_profile = driver_profile_result.scalar_one_or_none()
            if driver_profile:
                driver_profile.wallet_balance += delivery.driver_earning
                driver_profile.total_deliveries += 1

    await db.commit()

    return delivery


@router.get("/my-deliveries")
async def get_my_deliveries(
    status: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """الحصول على طلبات التوصيل الخاصة بي"""

    if current_user.role != "delivery_agent":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="فقط المندوبين"
        )

    query = select(Delivery).where(Delivery.delivery_agent_id == current_user.id)

    if status:
        query = query.where(Delivery.status == status)

    result = await db.execute(query.order_by(Delivery.created_at.desc()))
    deliveries = result.scalars().all()

    return deliveries


@router.get("/active")
async def get_active_delivery(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """الحصول على التوصيل النشط الحالي"""

    if current_user.role != "delivery_agent":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="فقط المندوبين"
        )

    result = await db.execute(
        select(Delivery).where(
            and_(
                Delivery.delivery_agent_id == current_user.id,
                Delivery.status.in_(["accepted", "picked_up"])
            )
        ).order_by(Delivery.created_at.desc())
    )
    delivery = result.scalar_one_or_none()

    return delivery


@router.put("/availability")
async def update_availability(
    is_available: bool,
    lat: Optional[float] = None,
    long: Optional[float] = None,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """تحديث حالة التوفر"""

    if current_user.role != "delivery_agent":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="فقط المندوبين"
        )

    result = await db.execute(
        select(DeliveryProfile).where(
            DeliveryProfile.user_id == current_user.id
        )
    )
    profile = result.scalar_one_or_none()

    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="الملف الشخصي غير موجود"
        )

    profile.is_available = is_available
    if lat:
        profile.current_lat = lat
    if long:
        profile.current_long = long

    await db.commit()

    return {"message": "تم تحديث حالة التوفر", "is_available": is_available}
