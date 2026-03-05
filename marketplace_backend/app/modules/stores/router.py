from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_
from sqlalchemy.orm import selectinload
from pydantic import BaseModel, Field
from typing import Optional, List
from math import radians, cos, sin, asin, sqrt

from app.database.session import get_db
from app.modules.users.models import User
from app.modules.stores.models import Store, StoreCategory, StoreStatus
from app.core.security import get_current_user

router = APIRouter()


# Pydantic Schemas
class StoreCategorySchema(BaseModel):
    id: int
    name_ar: str
    name_en: Optional[str] = None
    icon: Optional[str] = None
    image: Optional[str] = None

    class Config:
        from_attributes = True


class StoreSchema(BaseModel):
    id: int
    name: str
    slug: str
    description: Optional[str] = None
    logo: Optional[str] = None
    cover_image: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    district: Optional[str] = None
    lat: Optional[float] = None
    long: Optional[float] = None
    is_open: bool
    delivery_fee: float
    min_order: float
    delivery_time: int
    rating: float
    total_ratings: int
    total_orders: int
    status: str

    class Config:
        from_attributes = True


class StoreCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=255)
    description: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    district: Optional[str] = None
    lat: Optional[float] = None
    long: Optional[float] = None
    category_id: int
    delivery_type: str = "platform"
    delivery_fee: float = 5.0
    min_order: float = 0.0
    delivery_time: int = 30


# Helper function for distance calculation
def calculate_distance(lat1, lon1, lat2, lon2):
    """حساب المسافة بين نقطتين بالكيلومتر"""
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    return c * 6371  #半径


@router.get("/categories", response_model=List[StoreCategorySchema])
async def get_categories(
    parent_id: Optional[int] = None,
    db: AsyncSession = Depends(get_db)
):
    """الحصول على تصنيفات المتاجر"""
    query = select(StoreCategory).where(StoreCategory.is_active == True)
    if parent_id is not None:
        query = query.where(StoreCategory.parent_id == parent_id)
    else:
        query = query.where(StoreCategory.parent_id == None)

    result = await db.execute(query.order_by(StoreCategory.sort_order))
    return result.scalars().all()


@router.get("", response_model=List[StoreSchema])
async def get_stores(
    category_id: Optional[int] = None,
    city: Optional[str] = None,
    lat: Optional[float] = None,
    long: Optional[float] = None,
    radius: float = Query(default=10, ge=1, le=50),  # كم
    search: Optional[str] = None,
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    db: AsyncSession = Depends(get_db)
):
    """الحصول على قائمة المتاجر"""
    query = select(Store).where(
        and_(
            Store.status == StoreStatus.ACTIVE.value,
            Store.is_open == True
        )
    )

    if category_id:
        query = query.where(Store.category_id == category_id)

    if city:
        query = query.where(Store.city.ilike(f"%{city}%"))

    if search:
        query = query.where(
            or_(
                Store.name.ilike(f"%{search}%"),
                Store.description.ilike(f"%{search}%")
            )
        )

    result = await db.execute(query.order_by(Store.rating.desc()))
    stores = result.scalars().all()

    # تصفية حسب المسافة إذا توفر الموقع
    if lat and long:
        filtered_stores = []
        for store in stores:
            if store.lat and store.long:
                distance = calculate_distance(lat, long, store.lat, store.long)
                if distance <= radius:
                    filtered_stores.append(store)
        stores = filtered_stores
    else:
        stores = list(stores)

    # Pagination
    start = (page - 1) * limit
    end = start + limit
    return stores[start:end]


@router.get("/{store_id}", response_model=StoreSchema)
async def get_store(store_id: int, db: AsyncSession = Depends(get_db)):
    """الحصول على تفاصيل متجر"""
    result = await db.execute(
        select(Store).where(Store.id == store_id)
    )
    store = result.scalar_one_or_none()

    if not store:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="المتجر غير موجود"
        )

    return store


@router.post("", response_model=StoreSchema)
async def create_store(
    store_data: StoreCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """إنشاء متجر جديد (تاجر)"""

    if current_user.role != "vendor":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="فقط التجار يمكنهم إنشاء متاجر"
        )

    # إنشاء slug من الاسم
    slug = store_data.name.lower().replace(" ", "-")

    store = Store(
        vendor_id=current_user.id,
        category_id=store_data.category_id,
        name=store_data.name,
        slug=slug,
        description=store_data.description,
        phone=store_data.phone,
        email=store_data.email,
        address=store_data.address,
        city=store_data.city,
        district=store_data.district,
        lat=store_data.lat,
        long=store_data.long,
        delivery_type=store_data.delivery_type,
        delivery_fee=store_data.delivery_fee,
        min_order=store_data.min_order,
        delivery_time=store_data.delivery_time,
        status=StoreStatus.PENDING.value,
    )

    db.add(store)
    await db.commit()
    await db.refresh(store)

    return store


@router.put("/{store_id}")
async def update_store(
    store_id: int,
    store_data: StoreCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """تحديث بيانات المتجر"""

    result = await db.execute(
        select(Store).where(
            and_(Store.id == store_id, Store.vendor_id == current_user.id)
        )
    )
    store = result.scalar_one_or_none()

    if not store:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="المتجر غير موجود"
        )

    # تحديث البيانات
    for key, value in store_data.dict().items():
        if value is not None:
            setattr(store, key, value)

    await db.commit()
    await db.refresh(store)

    return store


@router.get("/nearby", response_model=List[StoreSchema])
async def get_nearby_stores(
    lat: float,
    long: float,
    radius: float = Query(default=5, ge=1, le=50),
    limit: int = Query(default=10, ge=1, le=50),
    db: AsyncSession = Depends(get_db)
):
    """الحصول على أقرب المتاجر"""

    result = await db.execute(
        select(Store).where(
            and_(
                Store.status == StoreStatus.ACTIVE.value,
                Store.is_open == True,
                Store.lat.isnot(None),
                Store.long.isnot(None)
            )
        )
    )
    stores = result.scalars().all()

    # حساب المسافة وترتيبها
    stores_with_distance = []
    for store in stores:
        distance = calculate_distance(lat, long, store.lat, store.long)
        if distance <= radius:
            stores_with_distance.append((store, distance))

    # ترتيب حسب المسافة
    stores_with_distance.sort(key=lambda x: x[1])

    return [store for store, _ in stores_with_distance[:limit]]
