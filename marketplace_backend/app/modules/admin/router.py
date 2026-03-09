from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, func, or_
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime, timedelta

from app.database.session import get_db
from app.modules.users.models import User, VendorProfile, DeliveryProfile, CustomerProfile
from app.modules.stores.models import Store, StoreCategory
from app.modules.orders.models import Order, OrderStatus
from app.core.security import get_current_user, require_role

router = APIRouter()


# Admin-only dependency
async def admin_required(current_user = Depends(require_role("admin"))):
    return current_user


# Statistics
@router.get("/stats")
async def get_stats(
    db: AsyncSession = Depends(get_db),
    current_user = Depends(admin_required)
):
    """إحصائيات النظام"""

    # عدد المستخدمين
    total_users = await db.scalar(select(func.count(User.id)))

    # عدد التجار
    total_vendors = await db.scalar(
        select(func.count(User.id)).where(User.role == "vendor")
    )

    # عدد المندوبين
    total_drivers = await db.scalar(
        select(func.count(User.id)).where(User.role == "delivery_agent")
    )

    # عدد المتاجر
    total_stores = await db.scalar(select(func.count(Store.id)))

    # عدد الطلبات
    total_orders = await db.scalar(select(func.count(Order.id)))

    # الطلبات اليوم
    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    today_orders = await db.scalar(
        select(func.count(Order.id)).where(Order.created_at >= today_start)
    )

    # إجمالي الأرباح (مثال)
    total_revenue = await db.scalar(
        select(func.sum(Order.total)).where(Order.status == OrderStatus.DELIVERED.value)
    )

    # أفضل المتاجر
    best_stores = await db.execute(
        select(Store.name, func.count(Order.id).label("order_count"))
        .join(Order, Order.store_id == Store.id)
        .group_by(Store.id)
        .order_by(func.count(Order.id).desc())
        .limit(5)
    )

    return {
        "total_users": total_users,
        "total_vendors": total_vendors,
        "total_drivers": total_drivers,
        "total_stores": total_stores,
        "total_orders": total_orders,
        "today_orders": today_orders,
        "total_revenue": float(total_revenue) if total_revenue else 0.0,
        "best_stores": [{"name": row[0], "orders": row[1]} for row in best_stores.fetchall()]
    }


# User Management
@router.get("/users")
async def get_users(
    role: Optional[str] = None,
    is_active: Optional[bool] = None,
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    current_user = Depends(admin_required)
):
    """الحصول على المستخدمين"""

    query = select(User)

    if role:
        query = query.where(User.role == role)

    if is_active is not None:
        query = query.where(User.is_active == is_active)

    result = await db.execute(query.order_by(User.created_at.desc()))
    users = result.scalars().all()

    # Pagination
    start = (page - 1) * limit
    end = start + limit

    return users[start:end]


@router.put("/users/{user_id}/status")
async def update_user_status(
    user_id: int,
    is_active: bool,
    db: AsyncSession = Depends(get_db),
    current_user = Depends(admin_required)
):
    """تفعيل/تعطيل مستخدم"""

    result = await db.execute(
        select(User).where(User.id == user_id)
    )
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="المستخدم غير موجود"
        )

    user.is_active = is_active
    await db.commit()

    return {"message": f"تم {'تفعيل' if is_active else 'تعطيل'} المستخدم بنجاح"}


# Vendor Management
@router.get("/vendors/pending")
async def get_pending_vendors(
    db: AsyncSession = Depends(get_db),
    current_user = Depends(admin_required)
):
    """الحصول على التجار في انتظار الموافقة"""

    result = await db.execute(
        select(User, VendorProfile).join(
            VendorProfile, VendorProfile.user_id == User.id
        ).where(
            and_(
                User.role == "vendor",
                VendorProfile.is_approved == False
            )
        )
    )

    vendors = []
    for user, profile in result.fetchall():
        vendors.append({
            "user_id": user.id,
            "full_name": user.full_name,
            "phone": user.phone,
            "email": user.email,
            "profile_id": profile.id
        })

    return vendors


@router.post("/vendors/{user_id}/approve")
async def approve_vendor(
    user_id: int,
    commission_rate: float = 0.10,
    db: AsyncSession = Depends(get_db),
    current_user = Depends(admin_required)
):
    """الموافقة على تاجر"""

    result = await db.execute(
        select(VendorProfile).where(VendorProfile.user_id == user_id)
    )
    profile = result.scalar_one_or_none()

    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="الملف الشخصي غير موجود"
        )

    profile.is_approved = True
    profile.commission_rate = commission_rate
    profile.approval_date = datetime.utcnow()

    await db.commit()

    return {"message": "تم الموافقة على التاجر بنجاح"}


# Delivery Agent Management
@router.get("/drivers/pending")
async def get_pending_drivers(
    db: AsyncSession = Depends(get_db),
    current_user = Depends(admin_required)
):
    """الحصول على المندوبين في انتظار الموافقة"""

    result = await db.execute(
        select(User, DeliveryProfile).join(
            DeliveryProfile, DeliveryProfile.user_id == User.id
        ).where(
            and_(
                User.role == "delivery_agent",
                DeliveryProfile.is_approved == False
            )
        )
    )

    drivers = []
    for user, profile in result.fetchall():
        drivers.append({
            "user_id": user.id,
            "full_name": user.full_name,
            "phone": user.phone,
            "vehicle_type": profile.vehicle_type,
            "profile_id": profile.id
        })

    return drivers


@router.post("/drivers/{user_id}/approve")
async def approve_driver(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user = Depends(admin_required)
):
    """الموافقة على مندوب"""

    result = await db.execute(
        select(DeliveryProfile).where(DeliveryProfile.user_id == user_id)
    )
    profile = result.scalar_one_or_none()

    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="الملف الشخصي غير موجود"
        )

    profile.is_approved = True

    await db.commit()

    return {"message": "تم الموافقة على المندوب بنuccessfully"}


# Store Management
@router.get("/stores")
async def get_all_stores(
    status: Optional[str] = None,
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    current_user = Depends(admin_required)
):
    """الحصول على المتاجر"""

    query = select(Store)

    if status:
        query = query.where(Store.status == status)

    result = await db.execute(query.order_by(Store.created_at.desc()))
    stores = result.scalars().all()

    # Pagination
    start = (page - 1) * limit
    end = start + limit

    return stores[start:end]


@router.put("/stores/{store_id}/status")
async def update_store_status(
    store_id: int,
    status: str,
    db: AsyncSession = Depends(get_db),
    current_user = Depends(admin_required)
):
    """تحديث حالة المتجر"""

    result = await db.execute(
        select(Store).where(Store.id == store_id)
    )
    store = result.scalar_one_or_none()

    if not store:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="المتجر غير موجود"
        )

    store.status = status
    await db.commit()

    return {"message": "تم تحديث حالة المتجر بنجاح"}


# Orders
@router.get("/orders")
async def get_all_orders(
    status: Optional[str] = None,
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    current_user = Depends(admin_required)
):
    """الحصول على جميع الطلبات"""

    query = select(Order)

    if status:
        query = query.where(Order.status == status)

    result = await db.execute(query.order_by(Order.created_at.desc()))
    orders = result.scalars().all()

    # Pagination
    start = (page - 1) * limit
    end = start + limit

    return orders[start:end]
