import { useState } from 'react';
import Head from 'next/head';
import Sidebar from '@/components/Sidebar';
import Header from '@/components/Header';
import DashboardHome from '@/components/DashboardHome';
import UsersManagement from '@/components/UsersManagement';
import StoresManagement from '@/components/StoresManagement';
import DriversManagement from '@/components/DriversManagement';
import OrdersManagement from '@/components/OrdersManagement';
import CategoriesManagement from '@/components/CategoriesManagement';
import ReportsPage from '@/components/ReportsPage';
import SettingsPage from '@/components/SettingsPage';

type PageType = 'dashboard' | 'users' | 'stores' | 'drivers' | 'orders' | 'categories' | 'reports' | 'settings';

export default function Home() {
  const [currentPage, setCurrentPage] = useState<PageType>('dashboard');
  const [sidebarOpen, setSidebarOpen] = useState(true);

  const renderPage = () => {
    switch (currentPage) {
      case 'dashboard':
        return <DashboardHome />;
      case 'users':
        return <UsersManagement />;
      case 'stores':
        return <StoresManagement />;
      case 'drivers':
        return <DriversManagement />;
      case 'orders':
        return <OrdersManagement />;
      case 'categories':
        return <CategoriesManagement />;
      case 'reports':
        return <ReportsPage />;
      case 'settings':
        return <SettingsPage />;
      default:
        return <DashboardHome />;
    }
  };

  return (
    <>
      <Head>
        <title>لوحة تحكم السوق الإلكتروني</title>
        <meta name="description" content="لوحة تحكم السوق الإلكتروني" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>
      <div className="flex h-screen bg-gray-50">
        <Sidebar
          currentPage={currentPage}
          setCurrentPage={setCurrentPage}
          isOpen={sidebarOpen}
          setIsOpen={setSidebarOpen}
        />
        <div className="flex-1 flex flex-col overflow-hidden">
          <Header toggleSidebar={() => setSidebarOpen(!sidebarOpen)} />
          <main className="flex-1 overflow-x-hidden overflow-y-auto bg-gray-50 p-6">
            {renderPage()}
          </main>
        </div>
      </div>
    </>
  );
}
