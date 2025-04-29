import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { SidebarLayout } from './layouts/SidebarLayout';
import { TodosLayout } from './layouts/TodoLayout';
import { TodoDetailPage } from './pages/todos/TodoDetailPage';
import { Toaster } from 'react-hot-toast';

export default function App() {
  return (
    <>
      <Routes>
        <Route path="/" element={<SidebarLayout />}>
          <Route index element={<Navigate to="/todo" replace />} />
          <Route path="/todo" element={<TodosLayout />}>
            <Route path=":id" element={<TodoDetailPage />} />
          </Route>
          <Route path="*" element={<h1 className='p-20 text-3xl'>Coming Soon...</h1>} />
        </Route>
      </Routes>
      <Toaster position="top-right" />
    </>
  );
}
