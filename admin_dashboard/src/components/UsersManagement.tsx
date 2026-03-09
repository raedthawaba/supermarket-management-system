import { useState } from 'react';
import { Search, Filter, MoreVertical, Eye, Ban, CheckCircle } from 'lucide-react';

export default function UsersManagement() {
  const [searchTerm, setSearchTerm] = useState('');
  const [roleFilter, setRoleFilter] = useState('all');

  const users = [
    { id: 1, name: 'أحمد محمد', email: 'ahmed@example.com', phone: '966501234567', role: 'customer', status: 'active', joined: '2024-01-15' },
    { id: 2, name: 'سارة علي', email: 'sara@example.com', phone: '966501234568', role: 'vendor', status: 'active', joined: '2024-01-10' },
    { id: 3, name: 'خالد عمر', email: 'khaled@example.com', phone: '966501234569', role: 'customer', status: 'inactive', joined: '2024-01-08' },
    { id: 4, name: 'منى يوسف', email: 'mona@example.com', phone: '966501234570', role: 'vendor', status: 'active', joined: '2024-01-05' },
    { id: 5, name: 'علي حسن', email: 'ali@example.com', phone: '966501234571', role: 'delivery_agent', status: 'active', joined: '2024-01-01' },
  ];

  const getRoleLabel = (role: string) => {
    switch (role) {
      case 'customer': return 'عميل';
      case 'vendor': return 'تاجر';
      case 'delivery_agent': return 'مندوب';
      case 'admin': return 'مدير';
      default: return role;
    }
  };

  const getRoleBadge = (role: string) => {
    switch (role) {
      case 'customer': return 'badge-info';
      case 'vendor': return 'badge-success';
      case 'delivery_agent': return 'badge-warning';
      default: return 'badge-info';
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">إدارة المستخدمين</h1>
          <p className="text-gray-500 mt-1">عرض وإدارة جميع المستخدمين</p>
        </div>
        <button className="btn-primary">
          إضافة مستخدم
        </button>
      </div>

      {/* Filters */}
      <div className="card">
        <div className="flex flex-col md:flex-row gap-4">
          {/* Search */}
          <div className="flex-1 relative">
            <Search className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="البحث بالاسم أو البريد الإلكتروني..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pr-10 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
            />
          </div>

          {/* Role Filter */}
          <select
            value={roleFilter}
            onChange={(e) => setRoleFilter(e.target.value)}
            className="px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
          >
            <option value="all">كل الأدوار</option>
            <option value="customer">عملاء</option>
            <option value="vendor">تجار</option>
            <option value="delivery_agent">مندوبين</option>
          </select>
        </div>
      </div>

      {/* Users Table */}
      <div className="card p-0">
        <div className="table-container">
          <table className="table">
            <thead>
              <tr>
                <th>الاسم</th>
                <th>البريد الإلكتروني</th>
                <th>الهاتف</th>
                <th>الدور</th>
                <th>الحالة</th>
                <th>تاريخ التسجيل</th>
                <th>إجراءات</th>
              </tr>
            </thead>
            <tbody>
              {users.map((user) => (
                <tr key={user.id}>
                  <td className="font-medium">{user.name}</td>
                  <td className="text-gray-600">{user.email}</td>
                  <td className="text-gray-600">{user.phone}</td>
                  <td>
                    <span className={`badge ${getRoleBadge(user.role)}`}>
                      {getRoleLabel(user.role)}
                    </span>
                  </td>
                  <td>
                    <span className={`badge ${user.status === 'active' ? 'badge-success' : 'badge-danger'}`}>
                      {user.status === 'active' ? 'نشط' : 'غير نشط'}
                    </span>
                  </td>
                  <td className="text-gray-600">{user.joined}</td>
                  <td>
                    <div className="flex items-center gap-2">
                      <button className="p-2 hover:bg-gray-100 rounded-lg" title="عرض">
                        <Eye className="w-4 h-4 text-gray-600" />
                      </button>
                      <button className="p-2 hover:bg-gray-100 rounded-lg" title={user.status === 'active' ? 'تعطيل' : 'تفعيل'}>
                        {user.status === 'active' ? (
                          <Ban className="w-4 h-4 text-red-500" />
                        ) : (
                          <CheckCircle className="w-4 h-4 text-green-500" />
                        )}
                      </button>
                      <button className="p-2 hover:bg-gray-100 rounded-lg">
                        <MoreVertical className="w-4 h-4 text-gray-600" />
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
