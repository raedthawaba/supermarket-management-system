from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
import random
import string

from app.database.session import get_db
from app.modules.users.models import User, CustomerProfile
from app.core.security import (
    get_password_hash,
    verify_password,
    create_access_token,
    create_refresh_token,
    decode_token,
    get_current_user
)

router = APIRouter()
security = HTTPBearer()


# Pydantic Schemas
class UserRegister(BaseModel):
    phone: str = Field(..., min_length=10, max_length=20)
    email: Optional[EmailStr] = None
    username: Optional[str] = None
    full_name: str
    password: str = Field(..., min_length=6)
    role: str = "customer"  # customer, vendor, delivery_agent


class UserLogin(BaseModel):
    phone: str
    password: str


class OTPRequest(BaseModel):
    phone: str


class OTPVerify(BaseModel):
    phone: str
    otp: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: dict


class SocialLogin(BaseModel):
    provider: str  # google, facebook
    provider_id: str
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    full_name: str
    avatar: Optional[str] = None


# Mock OTP storage (في الإنتاج يستخدم Redis)
otp_store = {}


def generate_otp():
    """توليد OTP عشوائي"""
    return ''.join(random.choices(string.digits, k=6))


@router.post("/register", response_model=TokenResponse)
async def register(user_data: UserRegister, db: AsyncSession = Depends(get_db)):
    """تسجيل مستخدم جديد"""

    # التحقق من وجود الهاتف
    result = await db.execute(
        select(User).where(User.phone == user_data.phone)
    )
    if result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="رقم الهاتف مسجل بالفعل"
        )

    # التحقق من البريد الإلكتروني إنُجد
    و if user_data.email:
        result = await db.execute(
            select(User).where(User.email == user_data.email)
        )
        if result.scalar_one_or_none():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="البريد الإلكتروني مسجل بالفعل"
            )

    # إنشاء المستخدم
    user = User(
        phone=user_data.phone,
        email=user_data.email,
        username=user_data.username,
        full_name=user_data.full_name,
        password_hash=get_password_hash(user_data.password),
        role=user_data.role,
        is_verified=False,
        is_active=True,
    )
    db.add(user)
    await db.flush()

    # إنشاء الملف الشخصي حسب الدور
    if user_data.role == "customer":
        profile = CustomerProfile(user_id=user.id)
        db.add(profile)

    await db.commit()
    await db.refresh(user)

    # إنشاء التوكن
    access_token = create_access_token({"sub": str(user.id)})
    refresh_token = create_refresh_token({"sub": str(user.id)})

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user={
            "id": user.id,
            "phone": user.phone,
            "email": user.email,
            "full_name": user.full_name,
            "role": user.role
        }
    )


@router.post("/login", response_model=TokenResponse)
async def login(credentials: UserLogin, db: AsyncSession = Depends(get_db)):
    """تسجيل الدخول"""
    result = await db.execute(
        select(User).where(User.phone == credentials.phone)
    )
    user = result.scalar_one_or_none()

    if not user or not verify_password(credentials.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="رقم الهاتف أو كلمة المرور غير صحيحة"
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="الحساب معطل"
        )

    # إنشاء التوكن
    access_token = create_access_token({"sub": str(user.id)})
    refresh_token = create_refresh_token({"sub": str(user.id)})

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user={
            "id": user.id,
            "phone": user.phone,
            "email": user.email,
            "full_name": user.full_name,
            "role": user.role
        }
    )


@router.post("/otp/send")
async def send_otp(request: OTPRequest, db: AsyncSession = Depends(get_db)):
    """إرسال OTP"""
    # التحقق من وجود المستخدم
    result = await db.execute(
        select(User).where(User.phone == request.phone)
    )
    user = result.scalar_one_or_none()

    # توليد OTP
    otp = generate_otp()
    otp_store[request.phone] = {
        "otp": otp,
        "expires": 300  # 5 دقائق
    }

    # TODO: إرسال OTP عبر SMS
    print(f"OTP for {request.phone}: {otp}")  # للاختبار فقط

    return {"message": "تم إرسال OTP", "otp": otp}  # إيزال OTP في الإنتاج


@router.post("/otp/verify")
async def verify_otp(verify: OTPVerify, db: AsyncSession = Depends(get_db)):
    """التحقق من OTP"""
    stored = otp_store.get(verify.phone)

    if not stored:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="لم يتم إرسال OTP"
        )

    if stored["otp"] != verify.otp:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="OTP غير صحيح"
        )

    # تفعيل المستخدم
    result = await db.execute(
        select(User).where(User.phone == verify.phone)
    )
    user = result.scalar_one_or_none()
    if user:
        user.is_verified = True
        await db.commit()

    # حذف OTP
    del otp_store[verify.phone]

    return {"message": "تم التحقق بنجاح"}


@router.post("/social/login", response_model=TokenResponse)
async def social_login(social: SocialLogin, db: AsyncSession = Depends(get_db)):
    """تسجيل الدخول عبر الشبكات الاجتماعية"""

    # البحث عن المستخدم
    result = await db.execute(
        select(User).where(User.email == social.email)
    )
    user = result.scalar_one_or_none()

    if not user:
        # إنشاء مستخدم جديد
        user = User(
            phone=social.phone or f"social_{social.provider_id}",
            email=social.email,
            full_name=social.full_name,
            avatar=social.avatar,
            role="customer",
            is_verified=True,
            is_active=True,
        )
        db.add(user)
        await db.flush()

        profile = CustomerProfile(user_id=user.id)
        db.add(profile)

    await db.commit()
    await db.refresh(user)

    # إنشاء التوكن
    access_token = create_access_token({"sub": str(user.id)})
    refresh_token = create_refresh_token({"sub": str(user.id)})

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user={
            "id": user.id,
            "phone": user.phone,
            "email": user.email,
            "full_name": user.full_name,
            "role": user.role
        }
    )


@router.post("/refresh")
async def refresh_token(
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """تحديث التوكن"""
    token = credentials.credentials
    payload = decode_token(token)

    if payload.get("type") != "refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token type"
        )

    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )

    # إنشاء توكن جديد
    access_token = create_access_token({"sub": user_id})
    refresh_token = create_refresh_token({"sub": user_id})

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }


@router.get("/me")
async def get_me(current_user = Depends(get_current_user)):
    """الحصول على بيانات المستخدم الحالي"""
    return {
        "id": current_user.id,
        "phone": current_user.phone,
        "email": current_user.email,
        "full_name": current_user.full_name,
        "role": current_user.role,
        "avatar": current_user.avatar,
        "is_verified": current_user.is_verified
    }
