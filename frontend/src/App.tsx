import { useState } from 'react';
import { Sidebar } from './components/Sidebar';
import { Header } from './components/Header';
import { DashboardPage } from './components/pages/DashboardPage';
import { ProfilePage } from './components/pages/ProfilePage';
import { DataUserPage } from './components/pages/DataUserPage';
import { SettingsPage } from './components/pages/SettingsPage';
import { LoginPage } from './components/pages/LoginPage';
import { Toaster } from './components/ui/sonner';

export default function App() {
  const [currentPage, setCurrentPage] = useState('dashboard');
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const handleLogin = () => {
    setIsLoggedIn(true);
    setCurrentPage('dashboard');
  };

  const handleLogout = () => {
    setIsLoggedIn(false);
    setCurrentPage('dashboard');
  };

  if (!isLoggedIn) {
    return <LoginPage onLogin={handleLogin} isDarkMode={isDarkMode} setIsDarkMode={setIsDarkMode} />;
  }

  const renderPage = () => {
    switch (currentPage) {
      case 'dashboard':
        return <DashboardPage isDarkMode={isDarkMode} />;
      case 'data-user':
        return <DataUserPage isDarkMode={isDarkMode} />;
      case 'profile':
        return <ProfilePage isDarkMode={isDarkMode} />;
      case 'settings':
        return <SettingsPage isDarkMode={isDarkMode} setIsDarkMode={setIsDarkMode} />;
      default:
        return <DashboardPage isDarkMode={isDarkMode} />;
    }
  };

  return (
    <>
      <div className={`min-h-screen ${isDarkMode ? 'bg-[#222831]' : 'bg-[#E6F4F1]'}`}>
        {/* Mobile Menu Overlay */}
        {isMobileMenuOpen && (
          <div 
            className="fixed inset-0 bg-black/50 z-40 lg:hidden"
            onClick={() => setIsMobileMenuOpen(false)}
          />
        )}

        <div className="flex h-screen overflow-hidden">
          {/* Sidebar */}
          <Sidebar 
            currentPage={currentPage}
            setCurrentPage={setCurrentPage}
            onLogout={handleLogout}
            isDarkMode={isDarkMode}
            isMobileMenuOpen={isMobileMenuOpen}
            setIsMobileMenuOpen={setIsMobileMenuOpen}
          />

          {/* Main Content */}
          <div className="flex-1 flex flex-col overflow-hidden">
            <Header 
              isDarkMode={isDarkMode}
              setIsDarkMode={setIsDarkMode}
              onMenuClick={() => setIsMobileMenuOpen(true)}
            />
            
            <main className="flex-1 overflow-y-auto">
              {renderPage()}
            </main>
          </div>
        </div>
      </div>
      <Toaster />
    </>
  );
}
