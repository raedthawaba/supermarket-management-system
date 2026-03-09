from sqlalchemy import Column, Integer, String, Boolean, DateTime, Enum, Float, Text, ForeignKey, Table
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum

from app.database.session import Base


class UserRole(str, enum.Enum):
    """أدوار المستخدمين"""
    CUSTOMER = "customer"
    VENDOR = "vendor"
    DELIVERY_AGENT = "delivery_agent"
    ADMIN = "admin"


class User(Base):
    """جدول المستخدمين"""
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=True)
    phone = Column(String(20), unique=True, index=True, nullable=False)
    username = Column(String(100), unique=True, index=True, nullable=True)
    full_name = Column(String(255), nullable=False)
    password_hash = Column(String(255), nullable=True)  # Nullable for social login
    role = Column(String(20), default=UserRole.CUSTOMER.value, nullable=False)
    avatar = Column(String(500), nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)
    is_verified = Column(Boolean, default=False, nullable=False)
    is_approved = Column(Boolean, default=False, nullable=False)  # للتجار والمندوبين
    fcm_token = Column(String(500), nullable=True)  # Firebase Cloud Messaging
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    customer_profile = relationship("CustomerProfile", back_populates="user", uselist=False)
    vendor_profile = relationship("VendorProfile", back_populates="user", uselist=False)
    delivery_profile = relationship("DeliveryProfile", back_populates="user", uselist=False)
    addresses = relationship("Address", back_populates="user")


class CustomerProfile(Base):
    """ملف العميل"""
    __tablename__ = "customer_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    loyalty_points = Column(Integer, default=0)
    total_orders = Column(Integer, default=0)
    wallet_balance = Column(Float, default=0.0)

    user = relationship("User", back_populates="customer_profile")


class VendorProfile(Base):
    """ملف التاجر"""
    __tablename__ = "vendor_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=True)
    identity_number = Column(String(50), nullable=True)
    business_license = Column(String(500), nullable=True)  # مسار صورة الرخصة
    commission_rate = Column(Float, default=0.10)  # 10% افتراضي
    wallet_balance = Column(Float, default=0.0)
    is_approved = Column(Boolean, default=False)
    approval_date = Column(DateTime(timezone=True), nullable=True)

    user = relationship("User", back_populates="vendor_profile")
    store = relationship("Store", back_populates="vendor_profile")


class DeliveryProfile(Base):
    """ملف مندوب التوصيل"""
    __tablename__ = "delivery_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    identity_number = Column(String(50), nullable=False)
    identity_image = Column(String(500), nullable=True)
    vehicle_type = Column(String(50), nullable=False)  # motorcycle, car, taxi, truck
    vehicle_model = Column(String(100), nullable=True)
    vehicle_color = Column(String(50), nullable=True)
    vehicle_plate = Column(String(20), nullable=True)
    work_region = Column(String(100), nullable=True)
    max_distance = Column(Float, default=10.0)  # كم
    work_type = Column(String(20), default="part_time")  # full_time, part_time
    guarantor_name = Column(String(255), nullable=True)
    guarantor_phone = Column(String(20), nullable=True)
    guarantor_identity = Column(String(500), nullable=True)
    insurance_amount = Column(Float, default=0.0)
    is_available = Column(Boolean, default=False)
    current_lat = Column(Float, nullable=True)
    current_long = Column(Float, nullable=True)
    wallet_balance = Column(Float, default=0.0)
    total_deliveries = Column(Integer, default=0)
    rating = Column(Float, default=5.0)
    is_approved = Column(Boolean, default=False)

    user = relationship("User", back_populates="delivery_profile")
    deliveries = relationship("Delivery", back_populates="delivery_agent")


class Address(Base):
    """عناوين المستخدم"""
    __tablename__ = "addresses"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    label = Column(String(100), nullable=True)  # منزل، عمل، آخر
    address = Column(Text, nullable=False)
    lat = Column(Float, nullable=True)
    long = Column(Float, nullable=True)
    city = Column(String(100), nullable=True)
    district = Column(String(100), nullable=True)
    street = Column(String(200), nullable=True)
    building = Column(String(50), nullable=True)
    floor = Column(String(20), nullable=True)
    apartment = Column(String(20), nullable=True)
    phone = Column(String(20), nullable=True)
    instructions = Column(Text, nullable=True)
    is_default = Column(Boolean, default=False)

    user = relationship("User", back_populates="addresses")
