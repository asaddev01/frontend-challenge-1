import React, { useState } from 'react';
import { Todo, todoListState } from '../state/todo.state';
import { useNavigate, useParams } from 'react-router-dom';
import { useRecoilState } from 'recoil';
import { AnimatePresence, usePresence, motion } from 'framer-motion';
import { FiTrash } from 'react-icons/fi';

interface TodoItemProps {
  todo: Todo;
}

export const TodoItem = ({ todo }: TodoItemProps) => {
  const { id, title, completed } = todo;
  const [, setTodos] = useRecoilState(todoListState);
  const navigate = useNavigate();
  const { id: todoId } = useParams();
  const [isPresent, safeToRemove] = usePresence();
  const [isDeleting, setIsDeleting] = useState(false); 

  const isSelected = todoId === String(id);

  const toggle = (id: number) =>
    setTodos((old) =>
      old.map((t) => (t.id === id ? { ...t, completed: !t.completed } : t))
    );

  const handleSelect = () => {
    navigate(`/todo/${id}`);
  };

  const handleDelete = () => {
    setIsDeleting(true);
    setTimeout(() => {
      setTodos((old) => old.filter((t) => t.id !== id));
    }, 1000); 
  };

  return (
    <AnimatePresence initial={false}>
      {isPresent && !isDeleting && (
        <motion.li
          key={id}
          className={`
            flex w-full cursor-pointer border rounded-lg py-1 px-4 space-x-3 
            ${isSelected ? 'bg-purple-500 text-white' : 'bg-white text-gray-900'} 
            group relative
          `}
          onClick={handleSelect}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -20 }}
          transition={{ duration: 0.3 }}
        >
          <input
            type="checkbox"
            checked={completed}
            onClick={(e) => e.stopPropagation()}
            onChange={() => toggle(id)}
            className={`
              w-5 h-5 border-2 rounded-full mt-2.5 cursor-pointer 
              border-purple-700 checked:accent-purple-700 checked:border-transparent
            `}
          />

          <div className="flex-1 pl-1 py-2">
            <p className={completed ? 'line-through' : ''}>{title}</p>
          </div>

          <motion.div
            className="absolute right-2 top-1/2 transform -translate-y-1/2 opacity-0 group-hover:opacity-100"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.15 }}
            onClick={(e: React.MouseEvent<HTMLDivElement>) => {
              e.stopPropagation();
              handleDelete();
            }}
          >
            <FiTrash
              size={18}
              className={`
                transition-colors 
                ${isSelected
                  ? 'text-white hover:text-red-50'
                  : 'text-gray-500 hover:text-red-600'}
              `}
              title="Delete todo"
            />
          </motion.div>
        </motion.li>
      )}
    </AnimatePresence>
  );
};
