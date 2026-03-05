from sqlalchemy import Column, Integer, String, Boolean, DateTime, Float, Text, ForeignKey, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum

from app.database.session import Base


class TransactionType(str, enum.Enum):
    """أنواع المعاملات"""
    ORDER_PAYMENT = "order_payment"
    ORDER_REFUND = "order_refund"
    WITHDRAWAL = "withdrawal"
    COMMISSION = "commission"
    DELIVERY_FEE = "delivery_fee"
    WALLET_TOPUP = "wallet_topup"
    BONUS = "bonus"


class TransactionStatus(str, enum.Enum):
    """حالات المعاملة"""
    PENDING = "pending"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


class Payment(Base):
    """المدفوعات"""
    __tablename__ = "payments"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    amount = Column(Float, nullable=False)
    method = Column(String(50), nullable=False)  # cash, card, wallet
    status = Column(String(20), default="pending")

    # Payment gateway info
    gateway = Column(String(50), nullable=True)  # stripe, paypal, etc.
    transaction_id = Column(String(200), nullable=True)
    gateway_response = Column(Text, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    order = relationship("Order", back_populates="payment")
    user = relationship("User", backref="payments")


class Wallet(Base):
    """المحافظ"""
    __tablename__ = "wallets"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    balance = Column(Float, default=0.0)
    frozen_balance = Column(Float, default=0.0)  # الرصيد المجمد

    user = relationship("User", backref="wallet")


class Transaction(Base):
    """المعاملات المالية"""
    __tablename__ = "transactions"

    id = Column(Integer, primary_key=True, index=True)
    wallet_id = Column(Integer, ForeignKey("wallets.id"), nullable=False)
    order_id = Column(Integer, ForeignKey("orders.id"), nullable=True)
    type = Column(String(50), nullable=False)
    amount = Column(Float, nullable=False)
    fee = Column(Float, default=0.0)  # العمولة
    net_amount = Column(Float, nullable=False)  # المبلغ الصافي
    status = Column(String(20), default="pending")
    description = Column(Text, nullable=True)
    reference_id = Column(String(200), nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    wallet = relationship("Wallet", backref="transactions")


class Withdrawal(Base):
    """طلبات السحب"""
    __tablename__ = "withdrawals"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    amount = Column(Float, nullable=False)
    method = Column(String(50), nullable=False)  # bank, wallet
    status = Column(String(20), default="pending")

    # Bank/Wallet details
    bank_name = Column(String(100), nullable=True)
    account_number = Column(String(50), nullable=True)
    iban = Column(String(50), nullable=True)
    wallet_number = Column(String(50), nullable=True)

    notes = Column(Text, nullable=True)
    processed_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", backref="withdrawals")
