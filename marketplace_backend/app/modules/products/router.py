from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_
from pydantic import BaseModel, Field
from typing import Optional, List

from app.database.session import get_db
from app.modules.users.models import User
from app.modules.products.models import Product, ProductCategory, ProductStatus
from app.modules.stores.models import Store
from app.core.security import get_current_user

router = APIRouter()


# Pydantic Schemas
class ProductCategorySchema(BaseModel):
    id: int
    name_ar: str
    name_en: Optional[str] = None
    icon: Optional[str] = None
    image: Optional[str] = None

    class Config:
        from_attributes = True


class ProductSchema(BaseModel):
    id: int
    store_id: int
    category_id: Optional[int] = None
    name: str
    slug: str
    description: Optional[str] = None
    image: Optional[str] = None
    images: Optional[str] = None
    price: float
    original_price: Optional[float] = None
    stock_quantity: int
    unit: Optional[str] = None
    status: str
    is_featured: bool
    rating: float
    total_ratings: int
    total_sold: int

    class Config:
        from_attributes = True


class ProductCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=255)
    description: Optional[str] = None
    category_id: Optional[int] = None
    price: float = Field(..., gt=0)
    original_price: Optional[float] = None
    cost_price: Optional[float] = None
    stock_quantity: int = 0
    unit: Optional[str] = "piece"
    sku: Optional[str] = None
    image: Optional[str] = None
    images: Optional[str] = None
    is_featured: bool = False
    min_order_quantity: int = 1
    max_order_quantity: int = 100
    weight: Optional[float] = None


class ProductUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    category_id: Optional[int] = None
    price: Optional[float] = None
    original_price: Optional[float] = None
    stock_quantity: Optional[int] = None
    unit: Optional[str] = None
    image: Optional[str] = None
    images: Optional[str] = None
    is_featured: Optional[bool] = None
    status: Optional[str] = None


@router.get("/categories", response_model=List[ProductCategorySchema])
async def get_categories(
    store_id: Optional[int] = None,
    parent_id: Optional[int] = None,
    db: AsyncSession = Depends(get_db)
):
    """الحصول على تصنيفات المنتجات"""
    query = select(ProductCategory).where(ProductCategory.is_active == True)

    if store_id:
        query = query.where(
            (ProductCategory.store_id == store_id) | (ProductCategory.store_id == None)
        )

    if parent_id is not None:
        query = query.where(ProductCategory.parent_id == parent_id)
    else:
        query = query.where(ProductCategory.parent_id == None)

    result = await db.execute(query.order_by(ProductCategory.sort_order))
    return result.scalars().all()


@router.get("", response_model=List[ProductSchema])
async def get_products(
    store_id: Optional[int] = None,
    category_id: Optional[int] = None,
    search: Optional[str] = None,
    featured: Optional[bool] = None,
    in_stock: Optional[bool] = None,
    sort_by: str = Query(default="created_at", regex="^(price|rating|created_at|total_sold)$"),
    sort_order: str = Query(default="desc", regex="^(asc|desc)$"),
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    db: AsyncSession = Depends(get_db)
):
    """الحصول على قائمة المنتجات"""
    query = select(Product).where(Product.status == ProductStatus.ACTIVE.value)

    if store_id:
        query = query.where(Product.store_id == store_id)

    if category_id:
        query = query.where(Product.category_id == category_id)

    if featured:
        query = query.where(Product.is_featured == True)

    if in_stock:
        query = query.where(Product.stock_quantity > 0)

    if search:
        query = query.where(
            or_(
                Product.name.ilike(f"%{search}%"),
                Product.description.ilike(f"%{search}%")
            )
        )

    # ترتيب
    if sort_order == "desc":
        query = query.order_by(getattr(Product, sort_by).desc())
    else:
        query = query.order_by(getattr(Product, sort_by).asc())

    result = await db.execute(query)
    products = result.scalars().all()

    # Pagination
    start = (page - 1) * limit
    end = start + limit
    return products[start:end]


@router.get("/{product_id}", response_model=ProductSchema)
async def get_product(product_id: int, db: AsyncSession = Depends(get_db)):
    """الحصول على تفاصيل منتج"""
    result = await db.execute(
        select(Product).where(Product.id == product_id)
    )
    product = result.scalar_one_or_none()

    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="المنتج غير موجود"
        )

    # زيادة عدد المشاهدات
    product.view_count += 1
    await db.commit()

    return product


@router.post("", response_model=ProductSchema)
async def create_product(
    product_data: ProductCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """إضافة منتج جديد (تاجر)"""

    if current_user.role != "vendor":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="فقط التجار يمكنهم إضافة منتجات"
        )

    # التحقق من ملكية المتجر
    result = await db.execute(
        select(Store).where(
            and_(Store.id == product_data.store_id, Store.vendor_id == current_user.id)
        )
    )
    store = result.scalar_one_or_none()

    if not store:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="المتجر غير موجود"
        )

    # إنشاء slug
    slug = product_data.name.lower().replace(" ", "-")

    product = Product(
        store_id=product_data.store_id,
        category_id=product_data.category_id,
        name=product_data.name,
        slug=slug,
        description=product_data.description,
        price=product_data.price,
        original_price=product_data.original_price,
        cost_price=product_data.cost_price,
        stock_quantity=product_data.stock_quantity,
        unit=product_data.unit,
        sku=product_data.sku,
        image=product_data.image,
        images=product_data.images,
        is_featured=product_data.is_featured,
        status=ProductStatus.ACTIVE.value,
        min_order_quantity=product_data.min_order_quantity,
        max_order_quantity=product_data.max_order_quantity,
        weight=product_data.weight,
    )

    db.add(product)
    await db.commit()
    await db.refresh(product)

    return product


@router.put("/{product_id}", response_model=ProductSchema)
async def update_product(
    product_id: int,
    product_data: ProductUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """تحديث منتج"""

    if current_user.role != "vendor":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="فقط التجار يمكنهم تحديث منتجات"
        )

    result = await db.execute(
        select(Product).where(
            and_(
                Product.id == product_id,
                Product.store_id.in_(
                    select(Store.id).where(Store.vendor_id == current_user.id)
                )
            )
        )
    )
    product = result.scalar_one_or_none()

    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="المنتج غير موجود"
        )

    # تحديث البيانات
    for key, value in product_data.dict(exclude_unset=True).items():
        setattr(product, key, value)

    await db.commit()
    await db.refresh(product)

    return product


@router.delete("/{product_id}")
async def delete_product(
    product_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """حذف منتج"""

    if current_user.role != "vendor":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="فقط التجار يمكنهم حذف منتجات"
        )

    result = await db.execute(
        select(Product).where(
            and_(
                Product.id == product_id,
                Product.store_id.in_(
                    select(Store.id).where(Store.vendor_id == current_user.id)
                )
            )
        )
    )
    product = result.scalar_one_or_none()

    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="المنتج غير موجود"
        )

    await db.delete(product)
    await db.commit()

    return {"message": "تم حذف المنتج بنجاح"}


@router.get("/store/{store_id}", response_model=List[ProductSchema])
async def get_store_products(
    store_id: int,
    category_id: Optional[int] = None,
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    db: AsyncSession = Depends(get_db)
):
    """الحصول على منتجات متجر محدد"""

    query = select(Product).where(
        and_(
            Product.store_id == store_id,
            Product.status == ProductStatus.ACTIVE.value
        )
    )

    if category_id:
        query = query.where(Product.category_id == category_id)

    result = await db.execute(query.order_by(Product.created_at.desc()))
    products = result.scalars().all()

    # Pagination
    start = (page - 1) * limit
    end = start + limit
    return products[start:end]
