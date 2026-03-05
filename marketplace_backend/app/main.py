from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.core.config import settings
from app.database.session import init_db


@asynccontextmanager
async def lifespan(app: FastAPI):
    """إدارة دورة حياة التطبيق"""
    # Startup
    print("Starting up...")
    await init_db()
    print("Database initialized")
    yield
    # Shutdown
    print("Shutting down...")


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Multi-Vendor Marketplace API",
    lifespan=lifespan,
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Import and include routers
from app.modules.auth.router import router as auth_router
from app.modules.users.router import router as users_router
from app.modules.stores.router import router as stores_router
from app.modules.products.router import router as products_router
from app.modules.orders.router import router as orders_router
from app.modules.delivery.router import router as delivery_router
from app.modules.payments.router import router as payments_router
from app.modules.reviews.router import router as reviews_router
from app.modules.admin.router import router as admin_router

# Include routers
app.include_router(auth_router, prefix=f"{settings.API_V1_PREFIX}/auth", tags=["Authentication"])
app.include_router(users_router, prefix=f"{settings.API_V1_PREFIX}/users", tags=["Users"])
app.include_router(stores_router, prefix=f"{settings.API_V1_PREFIX}/stores", tags=["Stores"])
app.include_router(products_router, prefix=f"{settings.API_V1_PREFIX}/products", tags=["Products"])
app.include_router(orders_router, prefix=f"{settings.API_V1_PREFIX}/orders", tags=["Orders"])
app.include_router(delivery_router, prefix=f"{settings.API_V1_PREFIX}/delivery", tags=["Delivery"])
app.include_router(payments_router, prefix=f"{settings.API_V1_PREFIX}/payments", tags=["Payments"])
app.include_router(reviews_router, prefix=f"{settings.API_V1_PREFIX}/reviews", tags=["Reviews"])
app.include_router(admin_router, prefix=f"{settings.API_V1_PREFIX}/admin", tags=["Admin"])


@app.get("/")
async def root():
    """الصفحة الرئيسية"""
    return {
        "name": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "status": "running"
    }


@app.get("/health")
async def health_check():
    """فحص صحة النظام"""
    return {"status": "healthy"}
