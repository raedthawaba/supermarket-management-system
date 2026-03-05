from sqlalchemy import Column, Integer, String, Boolean, DateTime, Float, Text, ForeignKey, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum

from app.database.session import Base


class OrderStatus(str, enum.Enum):
    """حالات الطلب"""
    PENDING = "pending"                    # بانتظار قبول التاجر
    ACCEPTED = "accepted"                  # مقبول من التاجر
    PREPARING = "preparing"               # قيد التجهيز
    READY_FOR_PICKUP = "ready_for_pickup" # جاهز للاستلام
    OUT_FOR_DELIVERY = "out_for_delivery" # في الطريق
    DELIVERED = "delivered"               # تم التسليم
    CANCELLED = "cancelled"                # ملغي


class PaymentMethod(str, enum.Enum):
    """طرق الدفع"""
    CASH = "cash"
    CARD = "card"
    WALLET = "wallet"


class PaymentStatus(str, enum.Enum):
    """حالات الدفع"""
    PENDING = "pending"
    PAID = "paid"
    FAILED = "failed"
    REFUNDED = "refunded"


class Order(Base):
    """الطلبات"""
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)
    order_number = Column(String(50), unique=True, index=True, nullable=False)
    customer_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=False)
    address_id = Column(Integer, ForeignKey("addresses.id"), nullable=True)

    # Financial
    subtotal = Column(Float, default=0.0)          # المجموع الفرعي
    discount = Column(Float, default=0.0)          # الخصم
    delivery_fee = Column(Float, default=0.0)     # رسوم التوصيل
    tax = Column(Float, default=0.0)               # الضريبة
    total = Column(Float, default=0.0)            # الإجمالي الكلي

    # Payment
    payment_method = Column(String(20), default=PaymentMethod.CASH.value)
    payment_status = Column(String(20), default=PaymentStatus.PENDING.value)
    transaction_id = Column(String(100), nullable=True)

    # Status
    status = Column(String(20), default=OrderStatus.PENDING.value)
    notes = Column(Text, nullable=True)
    cancel_reason = Column(String(500), nullable=True)

    # Timestamps
    accepted_at = Column(DateTime(timezone=True), nullable=True)
    preparing_at = Column(DateTime(timezone=True), nullable=True)
    ready_at = Column(DateTime(timezone=True), nullable=True)
    picked_up_at = Column(DateTime(timezone=True), nullable=True)
    delivered_at = Column(DateTime(timezone=True), nullable=True)
    cancelled_at = Column(DateTime(timezone=True), nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    customer = relationship("User", backref="orders")
    store = relationship("Store", back_populates="orders")
    address = relationship("Address")
    items = relationship("OrderItem", back_populates="order")
    delivery = relationship("Delivery", back_populates="order", uselist=False)
    payment = relationship("Payment", back_populates="order", uselist=False)
    reviews = relationship("Review", back_populates="order")


class OrderItem(Base):
    """عناصر الطلب"""
    __tablename__ = "order_items"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), nullable=False)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=False)

    # Product info at time of order
    product_name = Column(String(255), nullable=False)
    product_image = Column(String(500), nullable=True)
    product_price = Column(Float, nullable=False)

    quantity = Column(Integer, nullable=False)
    price = Column(Float, nullable=False)           # price * quantity
    discount = Column(Float, default=0.0)

    # Options/Attributes
    options = Column(Text, nullable=True)  # JSON

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    order = relationship("Order", back_populates="items")
    product = relationship("Product", back_populates="order_items")


class Delivery(Base):
    """التوصيل"""
    __tablename__ = "deliveries"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), unique=True, nullable=False)
    delivery_agent_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    delivery_type = Column(String(20), default="platform")  # platform, store_own

    # Status
    status = Column(String(20), default="pending")  # pending, accepted, picked_up, delivered, cancelled

    # Locations
    pickup_lat = Column(Float, nullable=True)
    pickup_long = Column(Float, nullable=True)
    delivery_lat = Column(Float, nullable=True)
    delivery_long = Column(Float, nullable=True)

    # Distance & Time
    distance_km = Column(Float, nullable=True)
    estimated_time = Column(Integer, nullable=True)  # minutes

    # Fees
    delivery_fee = Column(Float, default=0.0)
    driver_earning = Column(Float, default=0.0)

    # Timestamps
    accepted_at = Column(DateTime(timezone=True), nullable=True)
    picked_up_at = Column(DateTime(timezone=True), nullable=True)
    delivered_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    order = relationship("Order", back_populates="delivery")
    delivery_agent = relationship("DeliveryProfile", back_populates="deliveries")
