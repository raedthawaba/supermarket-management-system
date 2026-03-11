import { useState } from 'react';
import { Plus, Edit, Trash2, Eye } from 'lucide-react';

export default function CategoriesManagement() {
  const storeCategories = [
    { id: 1, name: 'إلكترونيات', icon: '💻', stores: 45, products: 320, status: 'active' },
    { id: 2, name: 'سوبرماركت', icon: '🛒', stores: 38, products: 890, status: 'active' },
    { id: 3, name: 'ملابس', icon: '👕', stores: 65, products: 450, status: 'active' },
    { id: 4, name: 'صيدلية', icon: '💊', stores: 22, products: 180, status: 'active' },
    { id: 5, name: 'مطاعم', icon: '🍔', stores: 55, products: 0, status: 'inactive' },
    { id: 6, name: 'قطع غيار', icon: '🔧', stores: 18, products: 250, status: 'active' },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">إدارة التصنيفات</h1>
          <p className="text-gray-500 mt-1">إدارة تصنيفات المتاجر والمنتجات</p>
        </div>
        <button className="btn-primary flex items-center gap-2">
          <Plus className="w-5 h-5" />
          إضافة تصنيف
        </button>
      </div>

      {/* Categories Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {storeCategories.map((category) => (
          <div key={category.id} className="card card-hover">
            <div className="flex items-start justify-between">
              <div className="flex items-center gap-3">
                <div className="w-14 h-14 bg-primary/10 rounded-xl flex items-center justify-center text-2xl">
                  {category.icon}
                </div>
                <div>
                  <h3 className="font-bold text-gray-800">{category.name}</h3>
                  <p className="text-sm text-gray-500">{category.stores} متجر</p>
                </div>
              </div>
              <span className={`badge ${category.status === 'active' ? 'badge-success' : 'badge-danger'}`}>
                {category.status === 'active' ? 'نشط' : 'غير نشط'}
              </span>
            </div>

            <div className="flex items-center justify-between mt-6 pt-4 border-t border-gray-100">
              <div className="text-sm text-gray-500">
                <span className="font-bold text-gray-800">{category.products}</span> منتج
              </div>
              <div className="flex items-center gap-2">
                <button className="p-2 hover:bg-gray-100 rounded-lg" title="عرض">
                  <Eye className="w-4 h-4 text-gray-600" />
                </button>
                <button className="p-2 hover:bg-gray-100 rounded-lg" title="تعديل">
                  <Edit className="w-4 h-4 text-gray-600" />
                </button>
                <button className="p-2 hover:bg-gray-100 rounded-lg" title="حذف">
                  <Trash2 className="w-4 h-4 text-red-500" />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
