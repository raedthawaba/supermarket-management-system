import { Download, Calendar, TrendingUp, Users, ShoppingCart, DollarSign } from 'lucide-react';

export default function ReportsPage() {
  const reportTypes = [
    { id: 1, title: 'تقرير المبيعات', description: 'تفاصيل المبيعات اليومية والأسبوعية والشهرية', icon: DollarSign, color: 'bg-green-500' },
    { id: 2, title: 'تقرير الطلبات', description: 'إحصائيات الطلبات وحالاتها', icon: ShoppingCart, color: 'bg-blue-500' },
    { id: 3, title: 'تقرير المستخدمين', description: 'إحصائيات المستخدمين الجدد والنشطين', icon: Users, color: 'bg-purple-500' },
    { id: 4, title: 'تقرير النمو', description: 'مقارنة الأداء عبر الفترات', icon: TrendingUp, color: 'bg-orange-500' },
  ];

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">التقارير</h1>
          <p className="text-gray-500 mt-1">عرض وتحميل التقارير المختلفة</p>
        </div>
      </div>

      <div className="card">
        <div className="flex items-center gap-4">
          <Calendar className="w-5 h-5 text-gray-400" />
          <span className="text-gray-600">الفترة الزمنية:</span>
          <select className="px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary">
            <option>اليوم</option>
            <option>هذا الأسبوع</option>
            <option>هذا الشهر</option>
            <option>الشهر الماضي</option>
            <option>السنة</option>
          </select>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {reportTypes.map((report) => {
          const Icon = report.icon;
          return (
            <div key={report.id} className="card card-hover">
              <div className="flex items-start gap-4">
                <div className={`${report.color} p-4 rounded-xl`}>
                  <Icon className="w-6 h-6 text-white" />
                </div>
                <div className="flex-1">
                  <h3 className="font-bold text-gray-800 text-lg">{report.title}</h3>
                  <p className="text-gray-500 text-sm mt-1">{report.description}</p>
                  <button className="mt-4 btn-secondary flex items-center gap-2 text-sm">
                    <Download className="w-4 h-4" />
                    تحميل التقرير
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      <div className="card">
        <h2 className="text-lg font-bold text-gray-800 mb-4">ملخص الفترة</h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {[
            { label: 'إجمالي المبيعات', value: '1,250,000 ر.س' },
            { label: 'إجمالي الطلبات', value: '8,450' },
            { label: 'متوسط قيمة الطلب', value: '148 ر.س' },
            { label: 'عمولة المنصة', value: '125,000 ر.س' },
          ].map((stat, index) => (
            <div key={index} className="p-4 bg-gray-50 rounded-lg text-center">
              <p className="text-gray-500 text-sm">{stat.label}</p>
              <p className="text-xl font-bold text-gray-800 mt-1">{stat.value}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
