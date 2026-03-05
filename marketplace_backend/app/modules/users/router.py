from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from pydantic import BaseModel, Field
from typing import Optional, List

from app.database.session import get_db
from app.modules.users.models import User, Address, CustomerProfile, VendorProfile, DeliveryProfile
from app.core.security import get_current_user

router = APIRouter()


# Pydantic Schemas
class AddressSchema(BaseModel):
    id: int
    label: Optional[str] = None
    address: str
    lat: Optional[float] = None
    long: Optional[float] = None
    city: Optional[str] = None
    district: Optional[str] = None
    street: Optional[str] = None
    building: Optional[str] = None
    floor: Optional[str] = None
    apartment: Optional[str] = None
    phone: Optional[str] = None
    instructions: Optional[str] = None
    is_default: bool

    class Config:
        from_attributes = True


class AddressCreate(BaseModel):
    label: Optional[str] = None
    address: str
    lat: Optional[float] = None
    long: Optional[float] = None
    city: Optional[str] = None
    district: Optional[str] = None
    street: Optional[str] = None
    building: Optional[str] = None
    floor: Optional[str] = None
    apartment: Optional[str] = None
    phone: Optional[str] = None
    instructions: Optional[str] = None
    is_default: bool = False


class ProfileUpdate(BaseModel):
    full_name: Optional[str] = None
    avatar: Optional[str] = None
    fcm_token: Optional[str] = None


@router.get("/profile")
async def get_profile(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """الحصول على الملف الشخصي"""

    profile_data = {
        "id": current_user.id,
        "phone": current_user.phone,
        "email": current_user.email,
        "full_name": current_user.full_name,
        "role": current_user.role,
        "avatar": current_user.avatar,
        "is_verified": current_user.is_verified
    }

    # إضافة البيانات الإضافية حسب الدور
    if current_user.role == "customer":
        result = await db.execute(
            select(CustomerProfile).where(CustomerProfile.user_id == current_user.id)
        )
        profile = result.scalar_one_or_none()
        if profile:
            profile_data["loyalty_points"] = profile.loyalty_points
            profile_data["total_orders"] = profile.total_orders
            profile_data["wallet_balance"] = profile.wallet_balance

    elif current_user.role == "vendor":
        result = await db.execute(
            select(VendorProfile).where(VendorProfile.user_id == current_user.id)
        )
        profile = result.scalar_one_or_none()
        if profile:
            profile_data["is_approved"] = profile.is_approved
            profile_data["wallet_balance"] = profile.wallet_balance
            profile_data["commission_rate"] = profile.commission_rate

    elif current_user.role == "delivery_agent":
        result = await db.execute(
            select(DeliveryProfile).where(DeliveryProfile.user_id == current_user.id)
        )
        profile = result.scalar_one_or_none()
        if profile:
            profile_data["is_approved"] = profile.is_approved
            profile_data["is_available"] = profile.is_available
            profile_data["wallet_balance"] = profile.wallet_balance
            profile_data["total_deliveries"] = profile.total_deliveries
            profile_data["rating"] = profile.rating
            profile_data["vehicle_type"] = profile.vehicle_type

    return profile_data


@router.put("/profile")
async def update_profile(
    profile_data: ProfileUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """تحديث الملف الشخصي"""

    if profile_data.full_name:
        current_user.full_name = profile_data.full_name
    if profile_data.avatar:
        current_user.avatar = profile_data.avatar
    if profile_data.fcm_token:
        current_user.fcm_token = profile_data.fcm_token

    await db.commit()
    await db.refresh(current_user)

    return {"message": "تم تحديث الملف الشخصي بنجاح"}


# Addresses
@router.get("/addresses", response_model=List[AddressSchema])
async def get_addresses(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """الحصول على العناوين"""

    result = await db.execute(
        select(Address).where(Address.user_id == current_user.id)
    )
    return result.scalars().all()


@router.post("/addresses", response_model=AddressSchema)
async def add_address(
    address_data: AddressCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """إضافة عنوان جديد"""

    # إذا كان العنوان افتراضياً، إلغاء العناوين الأخرى
    if address_data.is_default:
        result = await db.execute(
            select(Address).where(
                and_(
                    Address.user_id == current_user.id,
                    Address.is_default == True
                )
            )
        )
        for addr in result.scalars():
            addr.is_default = False

    address = Address(
        user_id=current_user.id,
        **address_data.dict()
    )

    db.add(address)
    await db.commit()
    await db.refresh(address)

    return address


@router.put("/addresses/{address_id}", response_model=AddressSchema)
async def update_address(
    address_id: int,
    address_data: AddressCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """تحديث عنوان"""

    result = await db.execute(
        select(Address).where(
            and_(
                Address.id == address_id,
                Address.user_id == current_user.id
            )
        )
    )
    address = result.scalar_one_or_none()

    if not address:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="العنوان غير موجود"
        )

    # إذا كان العنوان افتراضياً، إلغاء العناوين الأخرى
    if address_data.is_default:
        result = await db.execute(
            select(Address).where(
                and_(
                    Address.user_id == current_user.id,
                    Address.is_default == True,
                    Address.id != address_id
                )
            )
        )
        for addr in result.scalars():
            addr.is_default = False

    for key, value in address_data.dict().items():
        setattr(address, key, value)

    await db.commit()
    await db.refresh(address)

    return address


@router.delete("/addresses/{address_id}")
async def delete_address(
    address_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """حذف عنوان"""

    result = await db.execute(
        select(Address).where(
            and_(
                Address.id == address_id,
                Address.user_id == current_user.id
            )
        )
    )
    address = result.scalar_one_or_none()

    if not address:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="العنوان غير موجود"
        )

    await db.delete(address)
    await db.commit()

    return {"message": "تم حذف العنوان بنجاح"}


# Vendor Registration
@router.post("/become-vendor")
async def become_vendor(
    store_name: str,
    store_category_id: int,
    phone: str,
    identity_number: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """التقديم ليكون تاجر"""

    if current_user.role != "customer":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="لديك بالفعل حساب تاجر"
        )

    # إنشاء ملف تاجر
    vendor_profile = VendorProfile(
        user_id=current_user.id,
        identity_number=identity_number,
        is_approved=False
    )

    db.add(vendor_profile)
    await db.flush()

    # تحديث دور المستخدم
    current_user.role = "vendor"
    current_user.phone = phone

    await db.commit()

    return {"message": "تم تقديم طلب التحويل إلى تاجر بنجاح"}


# Delivery Agent Registration
@router.post("/become-driver")
async def become_driver(
    identity_number: str,
    vehicle_type: str,
    vehicle_model: Optional[str] = None,
    vehicle_color: Optional[str] = None,
    vehicle_plate: Optional[str] = None,
    work_region: Optional[str] = None,
    max_distance: float = 10.0,
    guarantor_name: Optional[str] = None,
    guarantor_phone: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """التقديم ليكون مندوب توصيل"""

    if current_user.role != "customer":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="لديك بالفعل حساب آخر"
        )

    # إنشاء ملف مندوب
    driver_profile = DeliveryProfile(
        user_id=current_user.id,
        identity_number=identity_number,
        vehicle_type=vehicle_type,
        vehicle_model=vehicle_model,
        vehicle_color=vehicle_color,
        vehicle_plate=vehicle_plate,
        work_region=work_region,
        max_distance=max_distance,
        guarantor_name=guarantor_name,
        guarantor_phone=guarantor_phone,
        is_approved=False
    )

    db.add(driver_profile)

    # تحديث دور المستخدم
    current_user.role = "delivery_agent"

    await db.commit()

    return {"message": "تم تقديم طلب التحويل إلى مندوب توصيل بنجاح"}
