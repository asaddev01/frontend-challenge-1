import { useState } from 'react';
import { Outlet, NavLink } from 'react-router-dom';
import { LuListTodo, LuCalendarDays, LuInbox, LuUser } from 'react-icons/lu';
import { HiMenu } from 'react-icons/hi';

export const SidebarLayout = () => {
  const [mobileOpen, setMobileOpen] = useState(false);

  return (
    <div className="flex min-h-screen">
      {!mobileOpen &&
      <button
        className="md:hidden fixed top-4 left-4 z-50 text-white bg-purple-900 p-2 rounded"
        onClick={() => setMobileOpen(!mobileOpen)}
      >
        <HiMenu className="h-6 w-6" />
      </button>
      }

      <aside
        className={`
          fixed inset-y-0 left-0 z-40 transform
          ${mobileOpen ? 'translate-x-0' : '-translate-x-full'}
          transition-transform duration-200
          md:translate-x-0 md:static
          w-64 md:w-64
          bg-purple-900 text-purple-100 p-6 flex flex-col justify-between shadow-lg
        `}
      >
        <div>
          <h2 className="text-2xl font-extrabold text-white mb-10 tracking-tight">
            Todo App
          </h2>

          <nav>
            <div className="flex flex-col space-y-1">
              <p className="text-white font-light text-xs mb-3 uppercase tracking-wide">
                General
              </p>

              {/** Reusable link styling */}
              {[
                { to: '/todo', icon: <LuListTodo />, label: 'Todos' },
                { to: '/calendar', icon: <LuCalendarDays />, label: 'Calendar' },
                { to: '/inbox', icon: <LuInbox />, label: 'Inbox' },
              ].map(({ to, icon, label }) => (
                <NavLink
                  key={to}
                  to={to}
                  className={({ isActive }) =>
                    `flex items-center space-x-3 px-4 py-2.5 rounded-md text-base font-medium transition-colors duration-200 ${
                      isActive
                        ? 'bg-purple-700 text-white'
                        : 'text-purple-300 hover:bg-purple-800 hover:text-white'
                    }`
                  }
                  onClick={() => setMobileOpen(false)} 
                >
                  <span className="text-lg">{icon}</span>
                  <span>{label}</span>
                </NavLink>
              ))}
            </div>
          </nav>
        </div>

        <div className="border-t border-purple-700 pt-6 mt-6 flex items-center space-x-3">
          <div className="bg-purple-800 p-2 rounded-full">
            <LuUser className="text-white text-xl" />
          </div>
          <div>
            <p className="text-white font-semibold text-sm">John Doe</p>
            <p className="text-purple-300 text-xs">View Account</p>
          </div>
        </div>
      </aside>

      {mobileOpen && (
        <div
          className="fixed inset-0 bg-black bg-opacity-40 z-30 md:hidden"
          onClick={() => setMobileOpen(false)}
        />
      )}

      {/* Main content */}
      <main className="flex-1 overflow-y-auto">
        <Outlet />
      </main>
    </div>
  );
};
