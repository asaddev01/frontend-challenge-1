import React, { useState } from 'react';
import { useUpdateTodo } from '../state/hooks';
import { FiEdit2, FiCheck, FiX } from 'react-icons/fi';
import { AnimatePresence, motion } from 'framer-motion';

interface FieldEditorProps {
  label: string;
  icon?: React.ReactNode;
  value?: string;
  type?: 'text' | 'textarea' | 'date' | 'select';
  options?: string[];
  fieldKey: keyof Omit<
    import('../state/todo.state').Todo,
    'id' | 'completed' | 'createdAt' | 'completedAt' | 'tags'
  >;
  todoId: number;
}

const FieldEditor: React.FC<FieldEditorProps> = ({
  label,
  icon,
  value = '',
  type = 'text',
  options = [],
  fieldKey,
  todoId,
}) => {
  const updateTodo = useUpdateTodo();
  const [editing, setEditing] = useState(false);
  const [draft, setDraft] = useState(value);

  const save = () => {
    updateTodo(todoId, { [fieldKey]: draft || undefined } as any);
    setEditing(false);
  };

  return (
    <div className="space-y-1">
      <div className="flex items-center justify-between">
        <span className="flex items-center gap-1 text-gray-600 text-xs font-light">
          {icon}
          {label}
        </span>
        {!editing && (
          <button
            onClick={() => setEditing(true)}
            title={`Edit ${label}`}
            className="p-1 text-gray-400 hover:text-gray-600 transition-colors"
          >
            <FiEdit2 />
          </button>
        )}
      </div>

      <AnimatePresence initial={false}>
        {editing ? (
          <motion.div
            key="editor"
            initial={{ opacity: 0, y: 5 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 5 }}
            className="flex items-center space-x-2"
          >
            {type === 'textarea' ? (
              <textarea
                autoFocus
                value={draft}
                onChange={(e) => setDraft(e.target.value)}
                className="flex-1 border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-purple-500"
              />
            ) : type === 'select' ? (
              <select
                autoFocus
                value={draft}
                onChange={(e) => setDraft(e.target.value)}
                className="flex-1 border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-purple-500"
              >
                <option value="">None</option>
                {options.map((opt) => (
                  <option key={opt} value={opt}>
                    {opt}
                  </option>
                ))}
              </select>
            ) : (
              <input
                autoFocus
                type={type}
                value={draft}
                onChange={(e) => setDraft(e.target.value)}
                className="flex-1 border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-purple-500"
              />
            )}

            <button
              onClick={() => setEditing(false)}
              title="Cancel"
              className="p-1 text-red-600 hover:text-red-800 transition-colors"
            >
              <FiX />
            </button>
            <button
              onClick={save}
              title="Save"
              className="p-1 text-green-600 hover:text-green-800 transition-colors"
            >
              <FiCheck />
            </button>
          </motion.div>
        ) : (
          <motion.p
            key="value"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="text-gray-800"
          >
            {value || <span className="text-gray-400">N/A</span>}
          </motion.p>
        )}
      </AnimatePresence>
    </div>
  );
};

export default FieldEditor;