from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from pydantic import BaseModel, Field
from typing import Optional

from app.database.session import get_db
from app.modules.users.models import User
from app.modules.payments.models import Wallet, Transaction, TransactionType, TransactionStatus, Withdrawal
from app.core.security import get_current_user

router = APIRouter()


# Pydantic Schemas
class WalletSchema(BaseModel):
    id: int
    balance: float
    frozen_balance: float

    class Config:
        from_attributes = True


class TransactionSchema(BaseModel):
    id: int
    wallet_id: int
    order_id: Optional[int] = None
    type: str
    amount: float
    fee: float
    net_amount: float
    status: str
    description: Optional[str] = None

    class Config:
        from_attributes = True


class WithdrawalRequest(BaseModel):
    amount: float = Field(..., gt=0)
    method: str  # bank, wallet
    bank_name: Optional[str] = None
    account_number: Optional[str] = None
    iban: Optional[str] = None
    wallet_number: Optional[str] = None


@router.get("/wallet", response_model=WalletSchema)
async def get_wallet(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """الحصول على المحفظة"""

    result = await db.execute(
        select(Wallet).where(Wallet.user_id == current_user.id)
    )
    wallet = result.scalar_one_or_none()

    if not wallet:
        # إنشاء محفظة جديدة
        wallet = Wallet(user_id=current_user.id, balance=0.0, frozen_balance=0.0)
        db.add(wallet)
        await db.commit()
        await db.refresh(wallet)

    return wallet


@router.get("/transactions", response_model=list[TransactionSchema])
async def get_transactions(
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """الحصول على المعاملات"""

    # الحصول على المحفظة
    result = await db.execute(
        select(Wallet).where(Wallet.user_id == current_user.id)
    )
    wallet = result.scalar_one_or_none()

    if not wallet:
        return []

    # الحصول على المعاملات
    result = await db.execute(
        select(Transaction).where(
            Transaction.wallet_id == wallet.id
        ).order_by(Transaction.created_at.desc())
    )
    transactions = result.scalars().all()

    # Pagination
    start = (page - 1) * limit
    end = start + limit

    return transactions[start:end]


@router.post("/withdraw")
async def request_withdrawal(
    withdrawal_data: WithdrawalRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """طلب سحب"""

    # الحصول على المحفظة
    result = await db.execute(
        select(Wallet).where(Wallet.user_id == current_user.id)
    )
    wallet = result.scalar_one_or_none()

    if not wallet:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="المحفظة غير موجودة"
        )

    # التحقق من الرصيد
    available_balance = wallet.balance - wallet.frozen_balance
    if withdrawal_data.amount > available_balance:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="الرصيد غير كافي"
        )

    # إنشاء طلب السحب
    withdrawal = Withdrawal(
        user_id=current_user.id,
        amount=withdrawal_data.amount,
        method=withdrawal_data.method,
        bank_name=withdrawal_data.bank_name,
        account_number=withdrawal_data.account_number,
        iban=withdrawal_data.iban,
        wallet_number=withdrawal_data.wallet_number,
        status="pending"
    )

    db.add(withdrawal)

    # تجميد الرصيد
    wallet.frozen_balance += withdrawal_data.amount

    await db.commit()

    return {"message": "تم تقديم طلب السحب بنجاح", "withdrawal_id": withdrawal.id}


@router.post("/topup")
async def topup_wallet(
    amount: float = Field(..., gt=0),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """شحن المحفظة"""

    # الحصول على المحفظة
    result = await db.execute(
        select(Wallet).where(Wallet.user_id == current_user.id)
    )
    wallet = result.scalar_one_or_none()

    if not wallet:
        wallet = Wallet(user_id=current_user.id, balance=0.0, frozen_balance=0.0)
        db.add(wallet)
        await db.flush()

    # إضافة الرصيد
    wallet.balance += amount

    # إنشاء معاملة
    transaction = Transaction(
        wallet_id=wallet.id,
        type=TransactionType.WALLET_TOPUP.value,
        amount=amount,
        fee=0.0,
        net_amount=amount,
        status=TransactionStatus.COMPLETED.value,
        description="شحن المحفظة"
    )

    db.add(transaction)
    await db.commit()

    return {"message": "تم شحن المحفظة بنجاح", "new_balance": wallet.balance}
