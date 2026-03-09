import { useState } from 'react';
import { Search, Store, Eye, Edit, Pause, Play, Star, MoreVertical } from 'lucide-react';

export default function StoresManagement() {
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');

  const stores = [
    { id: 1, name: 'متجر الإلكترونيات', owner: 'سارة علي', category: 'إلكترونيات', city: 'الرياض', status: 'active', rating: 4.8, orders: 450, commission: '10%' },
    { id: 2, name: 'سوبرماركت الحياة', owner: 'منى يوسف', category: 'سوبرماركت', city: 'جدة', status: 'active', rating: 4.6, orders: 380, commission: '10%' },
    { id: 3, name: 'متجر Clothing', owner: 'خالد عمر', category: 'ملابس', city: 'الدمام', status: 'pending', rating: 4.7, orders: 0, commission: '10%' },
    { id: 4, name: 'صيدلية الشفاء', owner: 'أحمد محمد', category: 'صيدلية', city: 'الرياض', status: 'active', rating: 4.9, orders: 280, commission: '12%' },
    { id: 5, name: 'متجر قطع غيار', owner: 'علي حسن', category: 'قطع غيار', city: 'جدة', status: 'suspended', rating: 4.2, orders: 120, commission: '10%' },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">إدارة المتاجر</h1>
          <p className="text-gray-500 mt-1">عرض وإدارة جميع المتاجر</p>
        </div>
        <button className="btn-primary">
          إضافة متجر
        </button>
      </div>

      {/* Filters */}
      <div className="card">
        <div className="flex flex-col md:flex-row gap-4">
          <div className="flex-1 relative">
            <Search className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="البحث باسم المتجر..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pr-10 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
            />
          </div>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
          >
            <option value="all">كل الحالات</option>
            <option value="active">نشط</option>
            <option value="pending">قيد المراجعة</option>
            <option value="suspended">معلق</option>
          </select>
        </div>
      </div>

      {/* Stores Table */}
      <div className="card p-0">
        <div className="table-container">
          <table className="table">
            <thead>
              <tr>
                <th>المتجر</th>
                <th>المالك</th>
                <th>الفئة</th>
                <th>المدينة</th>
                <th>التقييم</th>
                <th>الطلبات</th>
                <th>العمولة</th>
                <th>الحالة</th>
                <th>إجراءات</th>
              </tr>
            </thead>
            <tbody>
              {stores.map((store) => (
                <tr key={store.id}>
                  <td>
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center">
                        <Store className="w-5 h-5 text-primary" />
                      </div>
                      <span className="font-medium">{store.name}</span>
                    </div>
                  </td>
                  <td className="text-gray-600">{store.owner}</td>
                  <td className="text-gray-600">{store.category}</td>
                  <td className="text-gray-600">{store.city}</td>
                  <td>
                    <div className="flex items-center gap-1">
                      <Star className="w-4 h-4 text-yellow-500 fill-yellow-500" />
                      <span className="font-medium">{store.rating}</span>
                    </div>
                  </td>
                  <td className="text-gray-600">{store.orders}</td>
                  <td className="font-medium">{store.commission}</td>
                  <td>
                    <span className={`badge ${
                      store.status === 'active' ? 'badge-success' :
                      store.status === 'pending' ? 'badge-warning' :
                      'badge-danger'
                    }`}>
                      {store.status === 'active' ? 'نشط' :
                       store.status === 'pending' ? 'قيد المراجعة' :
                       'معلق'}
                    </span>
                  </td>
                  <td>
                    <div className="flex items-center gap-2">
                      <button className="p-2 hover:bg-gray-100 rounded-lg" title="عرض">
                        <Eye className="w-4 h-4 text-gray-600" />
                      </button>
                      <button className="p-2 hover:bg-gray-100 rounded-lg" title="تعديل">
                        <Edit className="w-4 h-4 text-gray-600" />
                      </button>
                      <button className="p-2 hover:bg-gray-100 rounded-lg" title={store.status === 'active' ? 'إيقاف' : 'تشغيل'}>
                        {store.status === 'active' ? (
                          <Pause className="w-4 h-4 text-red-500" />
                        ) : (
                          <Play className="w-4 h-4 text-green-500" />
                        )}
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
