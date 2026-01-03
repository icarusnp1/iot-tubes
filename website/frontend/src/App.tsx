import { useState } from 'react';
import { Sidebar } from './components/Sidebar';
import { Header } from './components/Header';
import { DashboardPage } from './components/pages/DashboardPage';
import { ProfilePage } from './components/pages/ProfilePage';
import { DataUserPage } from './components/pages/DataUserPage';
import { SettingsPage } from './components/pages/SettingsPage';
import { LoginPage } from './components/pages/LoginPage';
import { Toaster } from './components/ui/sonner';
import  RegisterPage  from './components/pages/RegisterPage';


export default function App() {
  const [currentPage, setCurrentPage] = useState('dashboard');
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [userId, setUserId] = useState<number | null>(null);

  const handleLogin = (id: number) => {
  setUserId(id);       // simpan userId
  setIsLoggedIn(true);
  setCurrentPage('dashboard');
};

  const handleLogout = async () => {
  try {
    await fetch("http://localhost/sem5/iot-tubes/website/backend/logout.php", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      }
    });
  } catch (err) {
    console.error("Logout error:", err);
  }

  setIsLoggedIn(false);   
  setUserId(null);   
  // 🔴 bersihkan frontend state
  localStorage.removeItem("user_id");
  setCurrentPage("login");
};

  if (!isLoggedIn) {
  if (currentPage === "register") {
    return (
      <RegisterPage
        onGoLogin={() => setCurrentPage("login")}
        isDarkMode={isDarkMode}
        setIsDarkMode={setIsDarkMode}
      />
    );
  }

  return (
    <LoginPage
  onLogin={handleLogin}  // sekarang sudah match (id: number) => void
  onGoRegister={() => setCurrentPage("register")}
  isDarkMode={isDarkMode}
  setIsDarkMode={setIsDarkMode}
/>
  );
}


  const renderPage = () => {
    switch (currentPage) {
      case 'dashboard':
        return userId ? <DashboardPage isDarkMode={isDarkMode} userId={userId} /> : null;
      case 'data-user':
        return userId ? <DataUserPage isDarkMode={isDarkMode} userId={userId} /> : null;
      case 'profile':
        return userId ? <ProfilePage isDarkMode={isDarkMode} userId={userId} /> : null;
      case 'settings':
        return <SettingsPage isDarkMode={isDarkMode} setIsDarkMode={setIsDarkMode} />;
      default:
        return userId ? <DashboardPage isDarkMode={isDarkMode} userId={userId} /> : null;
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
              userId={userId}
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
