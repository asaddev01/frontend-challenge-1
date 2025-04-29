import { useState } from 'react';
import { useSetRecoilState } from 'recoil';
import { todoListState } from '../state/todo.state';
import { IoIosAddCircleOutline } from 'react-icons/io';
import { motion, AnimatePresence } from 'framer-motion';
import toast from 'react-hot-toast';

export const AddTodo = () => {
  const [text, setText] = useState('');
  const [isOpen, setIsOpen] = useState(false);
  const [error, setError] = useState('');
  const [shake, setShake] = useState(false);
  const setTodos = useSetRecoilState(todoListState);

  const validate = () => {
    if (!text.trim()) {
      setError('Title cannot be empty.');
      triggerShake();
      return false;
    }
    if (text.length > 50) {
      setError('Title must be less than 50 characters.');
      triggerShake();
      return false;
    }
    setError('');
    return true;
  };

  const triggerShake = () => {
    setShake(true);
    setTimeout(() => setShake(false), 500);
  };

  const add = () => {
    if (!validate()) return;
    setTodos((old) => [
      ...old,
      {
        id: Date.now(),
        title: text.trim(),
        completed: false,
        createdAt: Date.now(),
      },
    ]);
    toast.success("Todo added successfully!")
    setText('');
    setIsOpen(false);
  };

  return (
    <>
      <div className="flex w-full justify-end items-end">
        <button
          onClick={() => setIsOpen(true)}
          className="flex items-center gap-2 bg-purple-600 hover:bg-purple-700 transition-colors text-white font-semibold px-4 py-2 rounded-lg shadow-md"
        >
          <IoIosAddCircleOutline size={20} />
          New Task
        </button>
      </div>

      {isOpen && (
        <div className="fixed inset-0 z-50 bg-black/40 flex items-center justify-center">
          <motion.div
            className="bg-white rounded-xl shadow-xl w-full max-w-md p-6 space-y-6"
            initial={{ scale: 0.95, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 0.95, opacity: 0 }}
            transition={{ type: 'spring', stiffness: 200, damping: 20 }}
          >
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-semibold">Add New Task</h2>
              <button
                onClick={() => {
                  setIsOpen(false);
                  setError('');
                }}
                className="text-gray-500 hover:text-gray-700 text-2xl font-bold"
              >
                &times;
              </button>
            </div>

            <div>
              <label className="block text-sm font-medium mb-1">Title</label>
              <motion.input
                key={shake ? 'shake' : 'no-shake'}
                type="text"
                value={text}
                onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
                  setText(e.target.value)
                }
                placeholder="Enter task title"
                className={`w-full border ${
                  error ? 'border-red-500' : 'border-gray-300'
                } rounded-lg px-4 py-2 focus:outline-none focus:ring-2 ${
                  error ? 'focus:ring-red-400' : 'focus:ring-purple-500'
                }`}
                animate={shake ? { x: [-5, 5, -5, 5, 0] } : {}}
                transition={{ duration: 0.4 }}
              />
              <AnimatePresence>
                {error && (
                  <motion.p
                    className="text-red-500 text-sm mt-1"
                    initial={{ opacity: 0, y: -4 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -4 }}
                  >
                    {error}
                  </motion.p>
                )}
              </AnimatePresence>
            </div>

            <div className="flex justify-end space-x-3">
              <button
                onClick={() => {
                  setIsOpen(false);
                  setError('');
                }}
                className="px-4 py-2 text-gray-600 hover:text-black"
              >
                Cancel
              </button>
              <button
                onClick={add}
                className="bg-purple-600 hover:bg-purple-700 text-white font-semibold px-4 py-2 rounded-lg"
              >
                Add Task
              </button>
            </div>
          </motion.div>
        </div>
      )}
    </>
  );
};
