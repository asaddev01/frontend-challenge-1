import { Outlet, useParams } from 'react-router-dom';
import { TodoList } from '../components/TodoList';
import { AddTodo } from '../components/AddTodo';
import { motion, AnimatePresence } from 'framer-motion';
import { useEffect, useState } from 'react';

export const TodosLayout = () => {
  const { id } = useParams();
  const [isDetailPage, setIsDetailPage] = useState(false);

  useEffect(() => {
    setIsDetailPage(Boolean(id));
  }, [id]);

  return (
    <div className="grid grid-cols-12 w-full h-full overflow-hidden">
      <div
        className={`${
          isDetailPage ? '!col-span-0 !hidden md:block md:col-span-8' : 'col-span-12'
        } pt-6 px-8 overflow-y-auto transition-all duration-300 ease-in-out ${
          isDetailPage ? 'border-r border-gray-200' : ''
        }`}
      >
        <div className="space-y-3 md:mt-0 mt-10 mb-12">
          <div className="flex items-center gap-3">
            <h3 className="text-sm font-medium text-gray-500">General</h3>
            <span className="inline-block w-1 h-1 bg-gray-400 rounded-full" />
            <h3 className="text-sm font-medium text-gray-500">Todo</h3>
          </div>
          <h1 className="text-3xl font-medium text-gray-900">Todo</h1>
        </div>
        <div className="mt-8 mb-6">
          <AddTodo />
        </div>
        <TodoList />
      </div>

      <AnimatePresence>
        {isDetailPage && (
          <motion.div
            className="col-span-12 mt-8 sm:mt-0 md:col-span-4 p-6 overflow-y-auto bg-white shadow-lg"
            initial={{ x: '100%', opacity: 0 }}
            animate={{ x: 0, opacity: 1 }}
            exit={{ x: '100%', opacity: 0 }}
            transition={{ type: 'spring', stiffness: 280, damping: 30 }}
            key="todo-detail"
          >
            <Outlet />
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};
