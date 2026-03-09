# سوق إلكتروني متعدد المتاجر - Multi-Vendor Marketplace

منصة سوق إلكتروني متعدد المتاجر مع نظام توصيل داخلي يشبه نماذج Uber وTalabat وAmazon.

## المكونات الرئيسية

### 1. الـ Backend (FastAPI)
المسار: `marketplace_backend/`

يحتوي على:
- نظام مصادقة شامل (JWT, OTP, Social Login)
- إدارة المستخدمين بأدوار متعددة (عميل، تاجر، مندوب، مدير)
- نظام متاجر متعدد التصنيفات
- نظام منتجات ومخزون
- نظام طلبات متكامل
- نظام توصيل ذكي
- نظام مدفوعات ومحافظ
- نظام تقييمات ومراجعات
- واجهات API RESTful

### 2. تطبيق الجوال (Flutter)
المسار: `marketplace_app/`

يحتوي على:
- تطبيق موحد للأدوار الثلاثة
- واجهات مستخدم للعميل
- واجهات التاجر
- واجهات المندوب
- دعم اللغتين العربية والإنجليزية

### 3. لوحة تحكم الإدارة (Next.js)
المسار: `admin_dashboard/`

تحتوي على:
- لوحة التحكم الرئيسية
- إدارة المستخدمين
- إدارة المتاجر
- إدارة المندوبين
- إدارة الطلبات
- إدارة التصنيفات
- التقارير والإحصائيات
- إعدادات النظام

## التقنيات المستخدمة

### Backend
- **Framework:** FastAPI
- **Database:** PostgreSQL
- **ORM:** SQLAlchemy (Async)
- **Authentication:** JWT + Bcrypt
- **API Documentation:** OpenAPI/Swagger

### Mobile App
- **Framework:** Flutter
- **State Management:** BLoC
- **Network:** Dio
- **Storage:** SharedPreferences

### Admin Dashboard
- **Framework:** Next.js 14
- **UI:** Tailwind CSS
- **Icons:** Lucide React
- **Charts:** Chart.js

## هيكل المشروع

```
MARKETPLACE-PLATFORM/
├── backend/                 # FastAPI Backend
│   ├── app/
│   │   ├── core/           # الإعدادات والأمان
│   │   ├── database/       # قاعدة البيانات
│   │   ├── modules/       # وحدات النظام
│   │   └── main.py        # نقطة الدخول
│   └── requirements.txt
│
├── mobile_app_flutter/     # تطبيق Flutter
│   ├── lib/
│   │   ├── core/          # الإعدادات الأساسية
│   │   ├── shared/        # المكونات المشتركة
│   │   └── modules/      # وحدات التطبيق
│   └── pubspec.yaml
│
├── admin_dashboard/        # لوحة التحكم
│   ├── src/
│   │   ├── components/    # مكونات React
│   │   ├── pages/        # صفحات Next.js
│   │   └── styles/       # أنماط CSS
│   └── package.json
│
└── README.md
```

## إعداد وتشغيل المشروع

### Backend

```bash
cd marketplace_backend
python -m venv venv
source venv/bin/activate  # Linux/Mac
# أو
venv\Scripts\activate  # Windows

pip install -r requirements.txt

# إنشاء ملف .env
cp .env.example .env

# تشغيل السيرفر
uvicorn app.main:app --reload
```

### Mobile App

```bash
cd marketplace_app
flutter pub get
flutter run
```

### Admin Dashboard

```bash
cd admin_dashboard
npm install
npm run dev
```

## متطلبات النظام

### Backend
- Python 3.10+
- PostgreSQL 14+
- Redis (اختياري)

### Mobile App
- Flutter 3.0+
- Dart 3.0+

### Admin Dashboard
- Node.js 18+
- npm 9+

## نظام الأدوار

1. **العميل (Customer):**
   - تصفح المتاجر والمنتجات
   - إضافة للسلة وإتمام الطلب
   - تتبع الطلبات وتقييمها

2. **التاجر (Vendor):**
   - إدارة المتجر والمنتجات
   - استقبال الطلبات وإدارتها
   - سحب الأرباح

3. **مندوب التوصيل (Delivery Agent):**
   - استقبال طلبات التوصيل
   - قبول وإنجاز التوصيل
   - متابعة الأرباح

4. **مدير النظام (Admin):**
   - الإشراف على جميع العمليات
   - إدارة المستخدمين والمتاجر
   -查看 التقارير والإحصائيات

## التراخيص

MIT License

## المطور

MiniMax Agent
