from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey, Enum, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum

from app.database.session import Base


class NotificationType(str, enum.Enum):
    """أنواع الإشعارات"""
    ORDER = "order"
    DELIVERY = "delivery"
    PAYMENT = "payment"
    PROMOTION = "promotion"
    SYSTEM = "system"
    REVIEW = "review"
    CHAT = "chat"


class Notification(Base):
    """الإشعارات"""
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    type = Column(String(20), nullable=False)
    title = Column(String(255), nullable=False)
    body = Column(Text, nullable=False)
    data = Column(JSON, nullable=True)  # بيانات إضافية

    # Channel
    is_push = Column(Boolean, default=True)
    is_sms = Column(Boolean, default=False)
    is_email = Column(Boolean, default=False)

    # Status
    is_read = Column(Boolean, default=False)
    read_at = Column(DateTime(timezone=True), nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", backref="notifications")


class NotificationTemplate(Base):
    """قوالب الإشعارات"""
    __tablename__ = "notification_templates"

    id = Column(Integer, primary_key=True, index=True)
    type = Column(String(20), unique=True, nullable=False)
    title_ar = Column(String(255), nullable=False)
    body_ar = Column(Text, nullable=False)
    title_en = Column(String(255), nullable=True)
    body_en = Column(Text, nullable=True)

    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())


class Report(Base):
    """التقارير"""
    __tablename__ = "reports"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    type = Column(String(50), nullable=False)  # abuse, bug, suggestion

    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    attachments = Column(Text, nullable=True)  # JSON array of image paths

    status = Column(String(20), default="pending")  # pending, reviewed, resolved
    admin_notes = Column(Text, nullable=True)
    resolved_at = Column(DateTime(timezone=True), nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", backref="reports")


class Dispute(Base):
    """النزاعات"""
    __tablename__ = "disputes"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    reason = Column(String(100), nullable=False)
    description = Column(Text, nullable=False)
    evidence = Column(Text, nullable=True)  # JSON

    status = Column(String(20), default="open")  # open, under_review, resolved, closed
    resolution = Column(Text, nullable=True)
    resolved_by = Column(Integer, ForeignKey("users.id"), nullable=True)
    resolved_at = Column(DateTime(timezone=True), nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    order = relationship("Order")
    user = relationship("User", foreign_keys=[user_id], backref="disputes")
    resolver = relationship("User", foreign_keys=[resolved_by])
