from sqlalchemy import Column, Integer, String, Boolean, DateTime, Float, Text, ForeignKey, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum

from app.database.session import Base


class ProductStatus(str, enum.Enum):
    """حالات المنتج"""
    DRAFT = "draft"
    ACTIVE = "active"
    INACTIVE = "inactive"
    OUT_OF_STOCK = "out_of_stock"


class ProductCategory(Base):
    """تصنيفات المنتجات"""
    __tablename__ = "product_categories"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=True)  # null للتصنيفات العامة
    name_ar = Column(String(100), nullable=False)
    name_en = Column(String(100), nullable=True)
    description = Column(Text, nullable=True)
    icon = Column(String(500), nullable=True)
    image = Column(String(500), nullable=True)
    parent_id = Column(Integer, ForeignKey("product_categories.id"), nullable=True)
    is_active = Column(Boolean, default=True)
    sort_order = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    parent = relationship("ProductCategory", remote_side=[id], backref="children")
    products = relationship("Product", back_populates="category")


class Product(Base):
    """المنتجات"""
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=False)
    category_id = Column(Integer, ForeignKey("product_categories.id"), nullable=True)
    name = Column(String(255), nullable=False)
    slug = Column(String(255), index=True)
    description = Column(Text, nullable=True)
    image = Column(String(500), nullable=True)
    images = Column(Text, nullable=True)  # JSON array of images
    price = Column(Float, nullable=False)
    original_price = Column(Float, nullable=True)  # للسعر قبل الخصم
    cost_price = Column(Float, nullable=True)  # سعر التكلفة
    stock_quantity = Column(Integer, default=0)
    unit = Column(String(50), nullable=True)  # كيلو، حبة، لتر، etc.
    sku = Column(String(100), nullable=True)
    barcode = Column(String(100), nullable=True)
    status = Column(String(20), default=ProductStatus.DRAFT.value)
    is_featured = Column(Boolean, default=False)
    is_approved = Column(Boolean, default=True)
    rating = Column(Float, default=5.0)
    total_ratings = Column(Integer, default=0)
    total_sold = Column(Integer, default=0)
    view_count = Column(Integer, default=0)
    min_order_quantity = Column(Integer, default=1)
    max_order_quantity = Column(Integer, default=100)
    weight = Column(Float, nullable=True)  # بالكيلو
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    store = relationship("Store", back_populates="products")
    category = relationship("ProductCategory", back_populates="products")
    order_items = relationship("OrderItem", back_populates="product")
    reviews = relationship("Review", back_populates="product")


class ProductAttribute(Base):
    """سمات المنتج (مثل: اللون، الحجم)"""
    __tablename__ = "product_attributes"

    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=False)
    name = Column(String(100), nullable=False)  # مثل: اللون
    value = Column(String(100), nullable=False)  # مثل: أحمر
    price = Column(Float, default=0.0)
    stock = Column(Integer, default=0)

    product = relationship("Product", backref="attributes")


class ProductOption(Base):
    """خيارات المنتج (مثل: صغير، وسط، كبير)"""
    __tablename__ = "product_options"

    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=False)
    name = Column(String(100), nullable=False)  # مثل: الحجم
    price_modifier = Column(Float, default=0.0)
    is_default = Column(Boolean, default=False)

    product = relationship("Product", backref="options")
    values = relationship("ProductOptionValue", back_populates="option")


class ProductOptionValue(Base):
    """قيم خيارات المنتج"""
    __tablename__ = "product_option_values"

    id = Column(Integer, primary_key=True, index=True)
    option_id = Column(Integer, ForeignKey("product_options.id"), nullable=False)
    value = Column(String(100), nullable=False)  # مثل: كبير
    price = Column(Float, default=0.0)
    stock = Column(Integer, default=0)

    option = relationship("ProductOption", back_populates="values")
