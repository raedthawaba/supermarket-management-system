from sqlalchemy import Column, Integer, String, Boolean, DateTime, Float, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.database.session import Base


class Delivery(Base):
    """جدول التوصيل"""
    __tablename__ = "deliveries"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), unique=True, nullable=False)
    delivery_agent_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    delivery_type = Column(String(20), default="platform")

    status = Column(String(20), default="pending")

    pickup_lat = Column(Float, nullable=True)
    pickup_long = Column(Float, nullable=True)
    delivery_lat = Column(Float, nullable=True)
    delivery_long = Column(Float, nullable=True)

    distance_km = Column(Float, nullable=True)
    estimated_time = Column(Integer, nullable=True)

    delivery_fee = Column(Float, default=0.0)
    driver_earning = Column(Float, default=0.0)

    accepted_at = Column(DateTime(timezone=True), nullable=True)
    picked_up_at = Column(DateTime(timezone=True), nullable=True)
    delivered_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    order = relationship("Order", back_populates="delivery")
    delivery_agent = relationship("DeliveryProfile", back_populates="deliveries")
