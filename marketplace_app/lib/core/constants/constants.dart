class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String otpSend = '/auth/otp/send';
  static const String otpVerify = '/auth/otp/verify';
  static const String socialLogin = '/auth/social/login';
  static const String refreshToken = '/auth/refresh';
  static const String me = '/auth/me';

  // Users
  static const String profile = '/users/profile';
  static const String addresses = '/users/addresses';
  static const String becomeVendor = '/users/become-vendor';
  static const String becomeDriver = '/users/become-driver';

  // Stores
  static const String stores = '/stores';
  static const String storeCategories = '/stores/categories';
  static const String nearbyStores = '/stores/nearby';

  // Products
  static const String products = '/products';
  static const String productCategories = '/products/categories';

  // Orders
  static const String orders = '/orders';
  static const String vendorOrders = '/orders/vendor';

  // Delivery
  static const String availableDeliveries = '/delivery/available';
  static const String myDeliveries = '/delivery/my-deliveries';
  static const String activeDelivery = '/delivery/active';
  static const String availability = '/delivery/availability';

  // Payments
  static const String wallet = '/payments/wallet';
  static const String transactions = '/payments/transactions';
  static const String withdraw = '/payments/withdraw';
  static const String topup = '/payments/topup';

  // Reviews
  static const String reviews = '/reviews';

  // Admin
  static const String adminStats = '/admin/stats';
  static const String adminUsers = '/admin/users';
  static const String adminVendors = '/admin/vendors';
  static const String adminDrivers = '/admin/drivers';
  static const String adminStores = '/admin/stores';
  static const String adminOrders = '/admin/orders';
}

class AppConstants {
  // Storage Keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userRole = 'user_role';
  static const String userId = 'user_id';
  static const String isLoggedIn = 'is_logged_in';
  static const String onboarding = 'onboarding';

  // Order Status
  static const String orderPending = 'pending';
  static const String orderAccepted = 'accepted';
  static const String orderPreparing = 'preparing';
  static const String orderReady = 'ready_for_pickup';
  static const String orderOutForDelivery = 'out_for_delivery';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';

  // User Roles
  static const String roleCustomer = 'customer';
  static const String roleVendor = 'vendor';
  static const String roleDriver = 'delivery_agent';
  static const String roleAdmin = 'admin';

  // Payment Methods
  static const String paymentCash = 'cash';
  static const String paymentCard = 'card';
  static const String paymentWallet = 'wallet';
}
