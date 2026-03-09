import { useState } from 'react';
import { Save, Settings, Bell, Shield, DollarSign, Truck, Percent } from 'lucide-react';

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState('general');

  const tabs = [
    { id: 'general', label: 'الإعدادات العامة', icon: Settings },
    { id: 'notifications', label: 'الإشعارات', icon: Bell },
    { id: 'commission', label: 'العمولات', icon: Percent },
    { id: 'delivery', label: 'التوصيل', icon: Truck },
    { id: 'security', label: 'الأمان', icon: Shield },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-800">الإعدادات</h1>
        <p className="text-gray-500 mt-1">إعدادات النظام المختلفة</p>
      </div>

      <div className="flex flex-col lg:flex-row gap-6">
        {/* Tabs */}
        <div className="lg:w-64 space-y-1">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg text-right transition-colors ${
                  activeTab === tab.id
                    ? 'bg-primary text-white'
                    : 'text-gray-600 hover:bg-gray-50'
                }`}
              >
                <Icon className="w-5 h-5" />
                <span className="font-medium">{tab.label}</span>
              </button>
            );
          })}
        </div>

        {/* Content */}
        <div className="flex-1">
          {activeTab === 'general' && (
            <div className="card">
              <h2 className="text-lg font-bold text-gray-800 mb-6">الإعدادات العامة</h2>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">اسم التطبيق</label>
                  <input type="text" defaultValue="سوق الإلكتروني" className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">البريد الإلكتروني للتواصل</label>
                  <input type="email" defaultValue="support@marketplace.com" className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">العملة الافتراضية</label>
                  <select className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary">
                    <option>ريال سعودي (SAR)</option>
                    <option>دولار أمريكي (USD)</option>
                    <option>جنيه مصري (EGP)</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">المنطقة الزمنية</label>
                  <select className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary">
                    <option>Asia/Riyadh (UTC+3)</option>
                    <option>Africa/Cairo (UTC+2)</option>
                    <option>Asia/Dubai (UTC+4)</option>
                  </select>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'commission' && (
            <div className="card">
              <h2 className="text-lg font-bold text-gray-800 mb-6">إعدادات العمولات</h2>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">عمولة المنصة الافتراضية (%)</label>
                  <input type="number" defaultValue="10" className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">نسبة مندوب التوصيل (%)</label>
                  <input type="number" defaultValue="80" className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">الحد الأدنى للسحب (ر.س)</label>
                  <input type="number" defaultValue="50" className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary" />
                </div>
              </div>
            </div>
          )}

          {activeTab === 'delivery' && (
            <div className="card">
              <h2 className="text-lg font-bold text-gray-800 mb-6">إعدادات التوصيل</h2>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">رسوم التوصيل الافتراضية (ر.س)</label>
                  <input type="number" defaultValue="5" className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">الحد الأقصى للمسافة (كم)</label>
                  <input type="number" defaultValue="50" className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">وقت التوصيل الافتراضي (دقيقة)</label>
                  <input type="number" defaultValue="30" className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary" />
                </div>
              </div>
            </div>
          )}

          {activeTab === 'notifications' && (
            <div className="card">
              <h2 className="text-lg font-bold text-gray-800 mb-6">إعدادات الإشعارات</h2>
              <div className="space-y-4">
                {[
                  { label: 'إشعارات الطلبات الجديدة', desc: 'إشعار عند وصول طلب جديد' },
                  { label: 'إشعارات التقييمات', desc: 'إشعار عند تقييم متجر أو مندوب' },
                  { label: 'إشعارات التسجيل', desc: 'إشعار عند تسجيل تاجر أو مندوب جديد' },
                  { label: 'إشعارات المالية', desc: 'إشعار عند طلب سحب أو إيداع' },
                ].map((item, index) => (
                  <div key={index} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                    <div>
                      <p className="font-medium text-gray-800">{item.label}</p>
                      <p className="text-sm text-gray-500">{item.desc}</p>
                    </div>
                    <label className="relative inline-flex items-center cursor-pointer">
                      <input type="checkbox" defaultChecked className="sr-only peer" />
                      <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary/20 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:right-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                    </label>
                  </div>
                ))}
              </div>
            </div>
          )}

          {activeTab === 'security' && (
            <div className="card">
              <h2 className="text-lg font-bold text-gray-800 mb-6">إعدادات الأمان</h2>
              <div className="space-y-4">
                <div className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                  <div>
                    <p className="font-medium text-gray-800">التحقق الثنائي</p>
                    <p className="text-sm text-gray-500">تفعيل التحقق بخطوتين عند الدخول</p>
                  </div>
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input type="checkbox" className="sr-only peer" />
                    <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary/20 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:right-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                  </label>
                </div>
                <div className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                  <div>
                    <p className="font-medium text-gray-800">تسجيل الخروج التلقائي</p>
                    <p className="text-sm text-gray-500">تسجيل الخروج بعد فترة من عدم النشاط</p>
                  </div>
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input type="checkbox" defaultChecked className="sr-only peer" />
                    <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary/20 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:right-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                  </label>
                </div>
              </div>
            </div>
          )}

          <div className="mt-6 flex justify-end">
            <button className="btn-primary flex items-center gap-2">
              <Save className="w-5 h-5" />
              حفظ الإعدادات
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
