from sqlalchemy import Column, Integer, String, Boolean, DateTime, Enum, Float, Text, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum

from app.database.session import Base


class StoreStatus(str, enum.Enum):
    """حالات المتجر"""
    PENDING = "pending"
    ACTIVE = "active"
    INACTIVE = "inactive"
    SUSPENDED = "suspended"
    REJECTED = "rejected"


class StoreCategory(Base):
    """تصنيفات المتاجر"""
    __tablename__ = "store_categories"

    id = Column(Integer, primary_key=True, index=True)
    name_ar = Column(String(100), nullable=False)
    name_en = Column(String(100), nullable=True)
    description = Column(Text, nullable=True)
    icon = Column(String(500), nullable=True)
    image = Column(String(500), nullable=True)
    parent_id = Column(Integer, ForeignKey("store_categories.id"), nullable=True)
    is_active = Column(Boolean, default=True)
    sort_order = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Self-referential relationship
    parent = relationship("StoreCategory", remote_side=[id], backref="children")
    stores = relationship("Store", back_populates="category")


class Store(Base):
    """المتاجر"""
    __tablename__ = "stores"

    id = Column(Integer, primary_key=True, index=True)
    vendor_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    category_id = Column(Integer, ForeignKey("store_categories.id"), nullable=False)
    name = Column(String(255), nullable=False)
    slug = Column(String(255), unique=True, index=True)
    description = Column(Text, nullable=True)
    logo = Column(String(500), nullable=True)
    cover_image = Column(String(500), nullable=True)
    phone = Column(String(20), nullable=True)
    email = Column(String(255), nullable=True)
    address = Column(Text, nullable=True)
    lat = Column(Float, nullable=True)
    long = Column(Float, nullable=True)
    city = Column(String(100), nullable=True)
    district = Column(String(100), nullable=True)
    status = Column(String(20), default=StoreStatus.PENDING.value)
    is_open = Column(Boolean, default=True)
    delivery_type = Column(String(20), default="platform")  # platform, store_own
    delivery_fee = Column(Float, default=5.0)
    min_order = Column(Float, default=0.0)
    delivery_time = Column(Integer, default=30)  # minutes
    rating = Column(Float, default=5.0)
    total_ratings = Column(Integer, default=0)
    total_orders = Column(Integer, default=0)
    commission_rate = Column(Float, default=0.10)
    wallet_balance = Column(Float, default=0.0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    vendor = relationship("VendorProfile", back_populates="store")
    category = relationship("StoreCategory", back_populates="stores")
    products = relationship("Product", back_populates="store")
    orders = relationship("Order", back_populates="store")
    reviews = relationship("Review", back_populates="store")


class StoreWorkingHours(Base):
    """أوقات عمل المتجر"""
    __tablename__ = "store_working_hours"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=False)
    day_of_week = Column(Integer, nullable=False)  # 0=Sunday, 6=Saturday
    open_time = Column(String(10), nullable=False)  # HH:MM
    close_time = Column(String(10), nullable=False)  # HH:MM
    is_closed = Column(Boolean, default=False)

    store = relationship("Store", backref="working_hours")
