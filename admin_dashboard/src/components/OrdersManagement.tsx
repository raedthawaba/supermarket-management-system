import { useState } from 'react';
import { Search, Eye, Clock, CheckCircle, XCircle, Truck, Package } from 'lucide-react';

export default function OrdersManagement() {
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');

  const orders = [
    { id: 'ORD-001', store: 'متجر الإلكترونيات', customer: 'أحمد محمد', total: '450 ر.س', status: 'pending', date: '2024-01-20 14:30', payment: 'cash' },
    { id: 'ORD-002', store: 'سوبرماركت الحياة', customer: 'سارة علي', total: '125 ر.س', status: 'accepted', date: '2024-01-20 13:45', payment: 'card' },
    { id: 'ORD-003', store: 'متجر Clothing', customer: 'خالد عمر', total: '320 ر.س', status: 'preparing', date: '2024-01-20 12:20', payment: 'wallet' },
    { id: 'ORD-004', store: 'صيدلية الشفاء', customer: 'منى يوسف', total: '85 ر.س', status: 'ready', date: '2024-01-20 11:10', payment: 'cash' },
    { id: 'ORD-005', store: 'متجر الإلكترونيات', customer: 'علي حسن', total: '2,100 ر.س', status: 'delivered', date: '2024-01-20 10:00', payment: 'card' },
    { id: 'ORD-006', store: 'سوبرماركت الحياة', customer: 'أحمد خالد', total: '75 ر.س', status: 'cancelled', date: '2024-01-20 09:30', payment: 'cash' },
  ];

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'pending': return <Clock className="w-4 h-4" />;
      case 'accepted': return <CheckCircle className="w-4 h-4" />;
      case 'preparing': return <Package className="w-4 h-4" />;
      case 'ready': return <Truck className="w-4 h-4" />;
      case 'delivered': return <CheckCircle className="w-4 h-4" />;
      case 'cancelled': return <XCircle className="w-4 h-4" />;
      default: return <Clock className="w-4 h-4" />;
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'pending': return 'badge-warning';
      case 'accepted': return 'badge-info';
      case 'preparing': return 'bg-purple-100 text-purple-800';
      case 'ready': return 'bg-cyan-100 text-cyan-800';
      case 'delivered': return 'badge-success';
      case 'cancelled': return 'badge-danger';
      default: return 'badge-info';
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'pending': return 'بانتظار التأكيد';
      case 'accepted': return 'تم القبول';
      case 'preparing': return 'قيد التجهيز';
      case 'ready': return 'جاهز للتسليم';
      case 'delivered': return 'تم التسليم';
      case 'cancelled': return 'ملغي';
      default: return status;
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">إدارة الطلبات</h1>
          <p className="text-gray-500 mt-1">عرض وتتبع جميع الطلبات</p>
        </div>
      </div>

      {/* Filters */}
      <div className="card">
        <div className="flex flex-col md:flex-row gap-4">
          <div className="flex-1 relative">
            <Search className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="البحث برقم الطلب..."
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
            <option value="pending">بانتظار التأكيد</option>
            <option value="accepted">تم القبول</option>
            <option value="preparing">قيد التجهيز</option>
            <option value="ready">جاهز للتسليم</option>
            <option value="delivered">تم التسليم</option>
            <option value="cancelled">ملغي</option>
          </select>
        </div>
      </div>

      {/* Orders Table */}
      <div className="card p-0">
        <div className="table-container">
          <table className="table">
            <thead>
              <tr>
                <th>رقم الطلب</th>
                <th>المتجر</th>
                <th>العميل</th>
                <th>الإجمالي</th>
                <th>الدفع</th>
                <th>التاريخ</th>
                <th>الحالة</th>
                <th>إجراءات</th>
              </tr>
            </thead>
            <tbody>
              {orders.map((order) => (
                <tr key={order.id}>
                  <td className="font-bold text-primary">{order.id}</td>
                  <td className="text-gray-600">{order.store}</td>
                  <td className="text-gray-600">{order.customer}</td>
                  <td className="font-bold">{order.total}</td>
                  <td>
                    <span className="text-sm text-gray-600">
                      {order.payment === 'cash' ? 'نقدي' :
                       order.payment === 'card' ? 'بطاقة' : 'محفظة'}
                    </span>
                  </td>
                  <td className="text-gray-600 text-sm">{order.date}</td>
                  <td>
                    <span className={`badge ${getStatusBadge(order.status)} flex items-center gap-1 w-fit`}>
                      {getStatusIcon(order.status)}
                      {getStatusLabel(order.status)}
                    </span>
                  </td>
                  <td>
                    <button className="p-2 hover:bg-gray-100 rounded-lg" title="عرض التفاصيل">
                      <Eye className="w-4 h-4 text-gray-600" />
                    </button>
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
