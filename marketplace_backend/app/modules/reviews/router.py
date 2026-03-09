from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, func
from pydantic import BaseModel, Field
from typing import Optional, List

from app.database.session import get_db
from app.modules.users.models import User
from app.modules.reviews.models import Review
from app.core.security import get_current_user

router = APIRouter()


# Pydantic Schemas
class ReviewCreate(BaseModel):
    order_id: int
    store_id: Optional[int] = None
    product_id: Optional[int] = None
    delivery_id: Optional[int] = None
    rating: float = Field(..., ge=1, le=5)
    comment: Optional[str] = None
    review_type: str  # store, product, delivery


class ReviewSchema(BaseModel):
    id: int
    user_id: int
    order_id: int
    store_id: Optional[int] = None
    product_id: Optional[int] = None
    delivery_id: Optional[int] = None
    rating: float
    comment: Optional[str] = None
    review_type: str

    class Config:
        from_attributes = True


@router.post("", response_model=ReviewSchema)
async def create_review(
    review_data: ReviewCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """إنشاء تقييم"""

    # التحقق من وجود الطلب
    from app.modules.orders.models import Order
    result = await db.execute(
        select(Order).where(Order.id == review_data.order_id)
    )
    order = result.scalar_one_or_none()

    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="الطلب غير موجود"
        )

    # التحقق من أن المستخدم هو صاحب الطلب
    if order.customer_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="ليس لديك صلاحية لتقييم هذا الطلب"
        )

    # التحقق من أن الطلب تم تسليمه
    if order.status != "delivered":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="يمكنك التقييم فقط بعد استلام الطلب"
        )

    # التحقق من عدم التقييم مسبقاً
    result = await db.execute(
        select(Review).where(
            and_(
                Review.order_id == review_data.order_id,
                Review.user_id == current_user.id,
                Review.review_type == review_data.review_type
            )
        )
    )
    existing_review = result.scalar_one_or_none()

    if existing_review:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="لقد قيمت هذا الطلب بالفعل"
        )

    # إنشاء التقييم
    review = Review(
        order_id=review_data.order_id,
        user_id=current_user.id,
        store_id=review_data.store_id,
        product_id=review_data.product_id,
        delivery_id=review_data.delivery_id,
        rating=review_data.rating,
        comment=review_data.comment,
        review_type=review_data.review_type,
    )

    db.add(review)

    # تحديث التقييم على المتجر أو المنتج أو المندوب
    if review_data.store_id:
        from app.modules.stores.models import Store
        result = await db.execute(
            select(Store).where(Store.id == review_data.store_id)
        )
        store = result.scalar_one_or_none()
        if store:
            # حساب التقييم الجديد
            result = await db.execute(
                select(func.avg(Review.rating), func.count(Review.id)).where(
                    Review.store_id == review_data.store_id
                )
            )
            avg_rating, total_ratings = result.first()
            store.rating = float(avg_rating) if avg_rating else review_data.rating
            store.total_ratings = total_ratings + 1

    if review_data.product_id:
        from app.modules.products.models import Product
        result = await db.execute(
            select(Product).where(Product.id == review_data.product_id)
        )
        product = result.scalar_one_or_none()
        if product:
            result = await db.execute(
                select(func.avg(Review.rating), func.count(Review.id)).where(
                    Review.product_id == review_data.product_id
                )
            )
            avg_rating, total_ratings = result.first()
            product.rating = float(avg_rating) if avg_rating else review_data.rating
            product.total_ratings = total_ratings + 1

    if review_data.delivery_id:
        from app.modules.users.models import DeliveryProfile
        result = await db.execute(
            select(DeliveryProfile).where(
                DeliveryProfile.user_id == review_data.delivery_id
            )
        )
        driver = result.scalar_one_or_none()
        if driver:
            result = await db.execute(
                select(func.avg(Review.rating)).where(
                    Review.delivery_id == review_data.delivery_id
                )
            )
            avg_rating = result.scalar_one_or_none()
            driver.rating = float(avg_rating) if avg_rating else review_data.rating

    await db.commit()
    await db.refresh(review)

    return review


@router.get("/store/{store_id}", response_model=List[ReviewSchema])
async def get_store_reviews(
    store_id: int,
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    db: AsyncSession = Depends(get_db)
):
    """الحصول على تقييمات متجر"""

    result = await db.execute(
        select(Review).where(
            and_(
                Review.store_id == store_id,
                Review.review_type == "store"
            )
        ).order_by(Review.created_at.desc())
    )
    reviews = result.scalars().all()

    # Pagination
    start = (page - 1) * limit
    end = start + limit

    return reviews[start:end]


@router.get("/product/{product_id}", response_model=List[ReviewSchema])
async def get_product_reviews(
    product_id: int,
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    db: AsyncSession = Depends(get_db)
):
    """الحصول على تقييمات منتج"""

    result = await db.execute(
        select(Review).where(
            and_(
                Review.product_id == product_id,
                Review.review_type == "product"
            )
        ).order_by(Review.created_at.desc())
    )
    reviews = result.scalars().all()

    # Pagination
    start = (page - 1) * limit
    end = start + limit

    return reviews[start:end]
