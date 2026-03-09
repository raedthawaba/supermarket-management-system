import { useState } from 'react';
import { Search, Truck, Eye, Edit, Star, MapPin, Phone, MoreVertical } from 'lucide-react';

export default function DriversManagement() {
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');

  const drivers = [
    { id: 1, name: 'محمد أحمد', phone: '966501234567', vehicle: 'دراجة نارية', city: 'الرياض', status: 'active', rating: 4.9, deliveries: 280, earnings: '14,000 ر.س', available: true },
    { id: 2, name: 'أحمد خالد', phone: '966501234568', vehicle: 'سيارة', city: 'جدة', status: 'active', rating: 4.8, deliveries: 245, earnings: '12,250 ر.س', available: true },
    { id: 3, name: 'علي محمد', phone: '966501234569', vehicle: 'تكسي', city: 'الدمام', status: 'pending', rating: 0, deliveries: 0, earnings: '0 ر.س', available: false },
    { id: 4, name: 'سعيد عمر', phone: '966501234570', vehicle: 'شاحنة صغيرة', city: 'الرياض', status: 'active', rating: 4.6, deliveries: 195, earnings: '9,750 ر.س', available: false },
    { id: 5, name: 'خالد يوسف', phone: '966501234571', vehicle: 'دراجة نارية', city: 'جدة', status: 'suspended', rating: 4.2, deliveries: 120, earnings: '6,000 ر.س', available: false },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">إدارة المندوبين</h1>
          <p className="text-gray-500 mt-1">عرض وإدارة جميع مندوبي التوصيل</p>
        </div>
        <button className="btn-primary">
          إضافة مندوب
        </button>
      </div>

      {/* Filters */}
      <div className="card">
        <div className="flex flex-col md:flex-row gap-4">
          <div className="flex-1 relative">
            <Search className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="البحث بالاسم أو الهاتف..."
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

      {/* Drivers Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {drivers.map((driver) => (
          <div key={driver.id} className="card card-hover">
            <div className="flex items-start justify-between mb-4">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center">
                  <Truck className="w-6 h-6 text-primary" />
                </div>
                <div>
                  <h3 className="font-bold text-gray-800">{driver.name}</h3>
                  <p className="text-sm text-gray-500">{driver.vehicle}</p>
                </div>
              </div>
              <span className={`badge ${
                driver.status === 'active' ? 'badge-success' :
                driver.status === 'pending' ? 'badge-warning' :
                'badge-danger'
              }`}>
                {driver.status === 'active' ? 'نشط' :
                 driver.status === 'pending' ? 'قيد المراجعة' :
                 'معلق'}
              </span>
            </div>

            <div className="space-y-3">
              <div className="flex items-center gap-2 text-sm text-gray-600">
                <Phone className="w-4 h-4" />
                <span>{driver.phone}</span>
              </div>
              <div className="flex items-center gap-2 text-sm text-gray-600">
                <MapPin className="w-4 h-4" />
                <span>{driver.city}</span>
              </div>
              <div className="flex items-center gap-2 text-sm text-gray-600">
                <Star className="w-4 h-4 text-yellow-500" />
                <span>{driver.rating > 0 ? driver.rating : 'جديد'}</span>
              </div>
            </div>

            <div className="flex items-center justify-between mt-4 pt-4 border-t border-gray-100">
              <div className="text-center">
                <p className="text-lg font-bold text-gray-800">{driver.deliveries}</p>
                <p className="text-xs text-gray-500">توصيلات</p>
              </div>
              <div className="text-center">
                <p className="text-lg font-bold text-green-600">{driver.earnings}</p>
                <p className="text-xs text-gray-500">أرباح</p>
              </div>
              <div className="flex items-center gap-2">
                <button className="p-2 hover:bg-gray-100 rounded-lg" title="عرض">
                  <Eye className="w-4 h-4 text-gray-600" />
                </button>
                <button className="p-2 hover:bg-gray-100 rounded-lg" title="تعديل">
                  <Edit className="w-4 h-4 text-gray-600" />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
