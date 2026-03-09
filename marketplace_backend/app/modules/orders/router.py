from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, func
from sqlalchemy.orm import selectinload
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
import uuid

from app.database.session import get_db
from app.modules.users.models import User, Address
from app.modules.stores.models import Store
from app.modules.products.models import Product
from app.modules.orders.models import Order, OrderItem, OrderStatus, PaymentMethod, PaymentStatus
from app.modules.delivery.models import Delivery
from app.core.security import get_current_user
from app.core.config import settings

router = APIRouter()


# Pydantic Schemas
class OrderItemSchema(BaseModel):
    id: int
    product_id: int
    product_name: str
    product_image: Optional[str] = None
    product_price: float
    quantity: int
    price: float

    class Config:
        from_attributes = True


class OrderSchema(BaseModel):
    id: int
    order_number: str
    customer_id: int
    store_id: int
    address_id: Optional[int] = None

    subtotal: float
    discount: float
    delivery_fee: float
    tax: float
    total: float

    payment_method: str
    payment_status: str
    status: str
    notes: Optional[str] = None

    created_at: datetime

    items: List[OrderItemSchema] = []
    store: Optional[dict] = None
    delivery: Optional[dict] = None

    class Config:
        from_attributes = True


class OrderItemCreate(BaseModel):
    product_id: int
    quantity: int = Field(..., gt=0)


class OrderCreate(BaseModel):
    store_id: int
    address_id: Optional[int] = None
    items: List[OrderItemCreate]
    payment_method: str = "cash"
    notes: Optional[str] = None


class OrderStatusUpdate(BaseModel):
    status: str


def generate_order_number():
    """توليد رقم طلب فريد"""
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    random_part = str(uuid.uuid4())[:6].upper()
    return f"ORD-{timestamp}-{random_part}"


@router.post("", response_model=OrderSchema)
async def create_order(
    order_data: OrderCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """إنشاء طلب جديد"""

    # التحقق من المتجر
    result = await db.execute(
        select(Store).where(Store.id == order_data.store_id)
    )
    store = result.scalar_one_or_none()

    if not store:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="المتجر غير موجود"
        )

    if not store.is_open:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="المتجر مغلق حالياً"
        )

    # التحقق من المنتجات وحساب المجموع
    subtotal = 0.0
    order_items = []

    for item_data in order_data.items:
        result = await db.execute(
            select(Product).where(Product.id == item_data.product_id)
        )
        product = result.scalar_one_or_none()

        if not product:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"المنتج {item_data.product_id} غير موجود"
            )

        if product.stock_quantity < item_data.quantity:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"الكمية المطلوبة من {product.name} غير متوفرة"
            )

        item_total = product.price * item_data.quantity
        subtotal += item_total

        order_items.append({
            "product_id": product.id,
            "product_name": product.name,
            "product_image": product.image,
            "product_price": product.price,
            "quantity": item_data.quantity,
            "price": item_total
        })

    # التحقق من الحد الأدنى للطلب
    if subtotal < store.min_order:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"الحد الأدنى للطلب هو {store.min_order}"
        )

    # حساب المجاميع
    delivery_fee = store.delivery_fee
    tax = subtotal * 0.15  # 15% ضريبة (قابلة للتغيير)
    discount = 0.0
    total = subtotal + delivery_fee + tax - discount

    # إنشاء الطلب
    order = Order(
        order_number=generate_order_number(),
        customer_id=current_user.id,
        store_id=order_data.store_id,
        address_id=order_data.address_id,

        subtotal=subtotal,
        discount=discount,
        delivery_fee=delivery_fee,
        tax=tax,
        total=total,

        payment_method=order_data.payment_method,
        payment_status=PaymentStatus.PENDING.value,
        status=OrderStatus.PENDING.value,
        notes=order_data.notes,
    )

    db.add(order)
    await db.flush()

    # إنشاء عناصر الطلب
    for item in order_items:
        order_item = OrderItem(
            order_id=order.id,
            **item
        )
        db.add(order_item)

        # خصم الكمية من المخزون
        result = await db.execute(
            select(Product).where(Product.id == item["product_id"])
        )
        product = result.scalar_one_or_none()
        product.stock_quantity -= item["quantity"]

    await db.commit()
    await db.refresh(order)

    # تحميل العلاقات
    result = await db.execute(
        select(Order).where(Order.id == order.id).options(
            selectinload(Order.items),
            selectinload(Order.store)
        )
    )
    order = result.scalar_one()

    return order


@router.get("", response_model=List[OrderSchema])
async def get_orders(
    status: Optional[str] = None,
    store_id: Optional[int] = None,
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """الحصول على قائمة الطلبات"""

    # بناء الاستعلام حسب الدور
    if current_user.role == "customer":
        query = select(Order).where(Order.customer_id == current_user.id)
    elif current_user.role == "vendor":
        query = select(Order).where(Order.store_id == store_id)
    else:
        query = select(Order)

    if status:
        query = query.where(Order.status == status)

    query = query.order_by(Order.created_at.desc())

    result = await db.execute(query)
    orders = result.scalars().all()

    # Pagination
    start = (page - 1) * limit
    end = start + limit

    return orders[start:end]


@router.get("/{order_id}", response_model=OrderSchema)
async def get_order(
    order_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """الحصول على تفاصيل طلب"""

    result = await db.execute(
        select(Order).where(Order.id == order_id).options(
            selectinload(Order.items),
            selectinload(Order.store),
            selectinload(Order.delivery)
        )
    )
    order = result.scalar_one_or_none()

    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="الطلب غير موجود"
        )

    # التحقق من الصلاحية
    if current_user.role == "customer" and order.customer_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="ليس لديك صلاحية viewing this order"
        )

    return order


@router.put("/{order_id}/status")
async def update_order_status(
    order_id: int,
    status_data: OrderStatusUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """تحديث حالة الطلب"""

    result = await db.execute(
        select(Order).where(Order.id == order_id)
    )
    order = result.scalar_one_or_none()

    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="الطلب غير موجود"
        )

    # التحقق من الصلاحية حسب الدور
    if current_user.role == "vendor":
        # التحقق من ملكية الطلب
        if order.store.vendor_id != current_user.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="ليس لديك صلاحية لتحديث هذا الطلب"
            )
    elif current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="ليس لديك صلاحية"
        )

    # التحقق من صحة الحالة
    valid_statuses = [s.value for s in OrderStatus]
    if status_data.status not in valid_statuses:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="حالة غير صالحة"
        )

    # تحديث الحالة والوقت
    order.status = status_data.status
    now = datetime.utcnow()

    if status_data.status == OrderStatus.ACCEPTED.value:
        order.accepted_at = now
    elif status_data.status == OrderStatus.PREPARING.value:
        order.preparing_at = now
    elif status_data.status == OrderStatus.READY_FOR_PICKUP.value:
        order.ready_at = now
    elif status_data.status == OrderStatus.DELIVERED.value:
        order.delivered_at = now
    elif status_data.status == OrderStatus.CANCELLED.value:
        order.cancelled_at = now

    await db.commit()
    await db.refresh(order)

    return order


@router.post("/{order_id}/cancel")
async def cancel_order(
    order_id: int,
    reason: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """إلغاء الطلب"""

    result = await db.execute(
        select(Order).where(Order.id == order_id)
    )
    order = result.scalar_one_or_none()

    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="الطلب غير موجود"
        )

    # التحقق من حالة الطلب
    if order.status not in [OrderStatus.PENDING.value, OrderStatus.ACCEPTED.value]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="لا يمكن إلغاء هذا الطلب"
        )

    # التحقق من الصلاحية
    if current_user.role == "customer" and order.customer_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="ليس لديك صلاحية"
        )

    # إلغاء الطلب
    order.status = OrderStatus.CANCELLED.value
    order.cancel_reason = reason
    order.cancelled_at = datetime.utcnow()

    # إعادة الكميات للمخزون
    for item in order.items:
        result = await db.execute(
            select(Product).where(Product.id == item.product_id)
        )
        product = result.scalar_one_or_none()
        if product:
            product.stock_quantity += item.quantity

    await db.commit()

    return {"message": "تم إلغاء الطلب بنجاح"}


@router.get("/vendor/{vendor_id}", response_model=List[OrderSchema])
async def get_vendor_orders(
    vendor_id: int,
    status: Optional[str] = None,
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    db: AsyncSession = Depends(get_db)
):
    """الحصول على طلبات تاجر محدد"""

    # الحصول على متاجر التاجر
    store_result = await db.execute(
        select(Store.id).where(Store.vendor_id == vendor_id)
    )
    store_ids = [row[0] for row in store_result.fetchall()]

    if not store_ids:
        return []

    query = select(Order).where(Order.store_id.in_(store_ids))

    if status:
        query = query.where(Order.status == status)

    query = query.order_by(Order.created_at.desc())

    result = await db.execute(query)
    orders = result.scalars().all()

    # Pagination
    start = (page - 1) * limit
    end = start + limit

    return orders[start:end]
