from sqlalchemy import Column, Integer, String, Boolean, DateTime, Float, Text, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.database.session import Base


class Review(Base):
    """التقييمات"""
    __tablename__ = "reviews"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=True)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=True)
    delivery_id = Column(Integer, ForeignKey("deliveries.id"), nullable=True)

    # Rating (1-5)
    rating = Column(Float, nullable=False)
    comment = Column(Text, nullable=True)

    # Review for
    review_type = Column(String(20), nullable=False)  # store, product, delivery

    # Media
    images = Column(Text, nullable=True)  # JSON array

    is_approved = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", backref="reviews")
    order = relationship("Order", back_populates="reviews")
    store = relationship("Store", back_populates="reviews")
    product = relationship("Product", back_populates="reviews")


class Coupon(Base):
    """الكوبونات"""
    __tablename__ = "coupons"

    id = Column(Integer, primary_key=True, index=True)
    code = Column(String(50), unique=True, nullable=False)
    description = Column(Text, nullable=True)

    # Discount type
    discount_type = Column(String(20), nullable=False)  # percentage, fixed
    discount_value = Column(Float, nullable=False)
    min_order_amount = Column(Float, default=0.0)
    max_discount_amount = Column(Float, nullable=True)

    # Usage limits
    usage_limit = Column(Integer, nullable=True)
    usage_count = Column(Integer, default=0)
    per_user_limit = Column(Integer, default=1)

    # Validity
    valid_from = Column(DateTime(timezone=True), nullable=True)
    valid_until = Column(DateTime(timezone=True), nullable=True)

    # Target
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=True)  # null = كل المتاجر
    category_id = Column(Integer, ForeignKey("product_categories.id"), nullable=True)

    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    store = relationship("Store", backref="coupons")


class UserCoupon(Base):
    """كوبونات المستخدم"""
    __tablename__ = "user_coupons"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    coupon_id = Column(Integer, ForeignKey("coupons.id"), nullable=False)
    used = Column(Boolean, default=False)
    used_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", backref="user_coupons")
    coupon = relationship("Coupon", backref="user_coupons")
