import { Users, Store, Truck, ShoppingCart, DollarSign, TrendingUp, TrendingDown } from 'lucide-react';

export default function DashboardHome() {
  const stats = [
    {
      title: 'إجمالي المستخدمين',
      value: '12,450',
      change: '+12%',
      trend: 'up',
      icon: Users,
      color: 'bg-blue-500',
    },
    {
      title: 'المتاجر النشطة',
      value: '850',
      change: '+8%',
      trend: 'up',
      icon: Store,
      color: 'bg-green-500',
    },
    {
      title: 'المندوبين',
      value: '245',
      change: '+5%',
      trend: 'up',
      icon: Truck,
      color: 'bg-purple-500',
    },
    {
      title: 'الطلبات اليوم',
      value: '1,230',
      change: '-3%',
      trend: 'down',
      icon: ShoppingCart,
      color: 'bg-orange-500',
    },
  ];

  const revenueStats = [
    { label: 'المبيعات اليومية', value: '45,200 ر.س' },
    { label: 'المبيعات الأسبوعية', value: '312,500 ر.س' },
    { label: 'المبيعات الشهرية', value: '1,250,000 ر.س' },
    { label: 'عمولة المنصة', value: '125,000 ر.س' },
  ];

  const recentOrders = [
    { id: 'ORD-001', store: 'متجر الإلكترونيات', customer: 'أحمد محمد', total: '450 ر.س', status: 'pending' },
    { id: 'ORD-002', store: 'سوبرماركت الحياة', customer: 'سارة علي', total: '125 ر.س', status: 'processing' },
    { id: 'ORD-003', store: 'متجر Clothing', customer: 'خالد عمر', total: '320 ر.س', status: 'delivered' },
    { id: 'ORD-004', store: 'صيدلية الشفاء', customer: 'منى يوسف', total: '85 ر.س', status: 'pending' },
    { id: 'ORD-005', store: 'متجر الإلكترونيات', customer: 'علي حسن', total: '2,100 ر.س', status: 'processing' },
  ];

  return (
    <div className="space-y-6">
      {/* Page Title */}
      <div>
        <h1 className="text-2xl font-bold text-gray-800">لوحة التحكم</h1>
        <p className="text-gray-500 mt-1">مرحباً بك في لوحة تحكم السوق الإلكتروني</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat, index) => {
          const Icon = stat.icon;
          const TrendIcon = stat.trend === 'up' ? TrendingUp : TrendingDown;
          const trendColor = stat.trend === 'up' ? 'text-green-500' : 'text-red-500';

          return (
            <div key={index} className="card card-hover">
              <div className="flex items-start justify-between">
                <div>
                  <p className="text-gray-500 text-sm">{stat.title}</p>
                  <p className="text-2xl font-bold text-gray-800 mt-2">{stat.value}</p>
                  <div className={`flex items-center gap-1 mt-2 ${trendColor}`}>
                    <TrendIcon className="w-4 h-4" />
                    <span className="text-sm font-medium">{stat.change}</span>
                    <span className="text-gray-400 text-sm">من الأسبوع الماضي</span>
                  </div>
                </div>
                <div className={`${stat.color} p-3 rounded-xl`}>
                  <Icon className="w-6 h-6 text-white" />
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Revenue & Orders */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Revenue Stats */}
        <div className="card">
          <h2 className="text-lg font-bold text-gray-800 mb-4">الإحصائيات المالية</h2>
          <div className="space-y-4">
            {revenueStats.map((stat, index) => (
              <div key={index} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <span className="text-gray-600">{stat.label}</span>
                <span className="font-bold text-primary">{stat.value}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Recent Orders */}
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-bold text-gray-800">الطلبات الأخيرة</h2>
            <button className="text-primary text-sm font-medium hover:underline">
              عرض الكل
            </button>
          </div>
          <div className="table-container">
            <table className="table">
              <thead>
                <tr>
                  <th>رقم الطلب</th>
                  <th>المتجر</th>
                  <th>العميل</th>
                  <th>الإجمالي</th>
                  <th>الحالة</th>
                </tr>
              </thead>
              <tbody>
                {recentOrders.map((order) => (
                  <tr key={order.id}>
                    <td className="font-medium">{order.id}</td>
                    <td className="text-gray-600">{order.store}</td>
                    <td className="text-gray-600">{order.customer}</td>
                    <td className="font-bold">{order.total}</td>
                    <td>
                      <span className={`badge ${
                        order.status === 'pending' ? 'badge-warning' :
                        order.status === 'processing' ? 'badge-info' :
                        'badge-success'
                      }`}>
                        {order.status === 'pending' ? 'قيد الانتظار' :
                         order.status === 'processing' ? 'قيد التجهيز' :
                         'تم التسليم'}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* Top Stores & Drivers */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Top Stores */}
        <div className="card">
          <h2 className="text-lg font-bold text-gray-800 mb-4">أفضل المتاجر</h2>
          <div className="space-y-4">
            {[
              { name: 'متجر الإلكترونيات', orders: 450, rating: 4.8 },
              { name: 'سوبرماركت الحياة', orders: 380, rating: 4.6 },
              { name: 'متجر Clothing', orders: 320, rating: 4.7 },
              { name: 'صيدلية الشفاء', orders: 280, rating: 4.9 },
            ].map((store, index) => (
              <div key={index} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <div className="flex items-center gap-3">
                  <span className="w-8 h-8 bg-primary rounded-full flex items-center justify-center text-white font-bold text-sm">
                    {index + 1}
                  </span>
                  <div>
                    <p className="font-medium text-gray-800">{store.name}</p>
                    <p className="text-xs text-gray-500">{store.orders} طلب</p>
                  </div>
                </div>
                <div className="flex items-center gap-1">
                  <span className="text-yellow-500">★</span>
                  <span className="font-medium">{store.rating}</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Top Drivers */}
        <div className="card">
          <h2 className="text-lg font-bold text-gray-800 mb-4">أفضل المندوبين</h2>
          <div className="space-y-4">
            {[
              { name: 'محمد أحمد', deliveries: 280, rating: 4.9 },
              { name: 'أحمد خالد', deliveries: 245, rating: 4.8 },
              { name: 'علي محمد', deliveries: 220, rating: 4.7 },
              { name: 'سعيد عمر', deliveries: 195, rating: 4.6 },
            ].map((driver, index) => (
              <div key={index} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <div className="flex items-center gap-3">
                  <span className="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center text-white font-bold text-sm">
                    {index + 1}
                  </span>
                  <div>
                    <p className="font-medium text-gray-800">{driver.name}</p>
                    <p className="text-xs text-gray-500">{driver.deliveries} توصيل</p>
                  </div>
                </div>
                <div className="flex items-center gap-1">
                  <span className="text-yellow-500">★</span>
                  <span className="font-medium">{driver.rating}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
