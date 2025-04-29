import React from 'react';
import { useRecoilValue } from 'recoil';
import { useNavigate, useParams } from 'react-router-dom';
import { todoByIdState } from '../../state/todo.state';
import FieldEditor from '../../components/FieldEditor';
import { IoArrowBackOutline } from 'react-icons/io5';

export const TodoDetailPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const todoId = Number(id);
  const todo = useRecoilValue(todoByIdState(todoId));

  if (!id) {
    return (
      <div className="text-gray-400 text-center mt-20">
        Select a Todo to see details
      </div>
    );
  }

  if (!todo) {
    return (
      <div className="text-gray-400 text-center mt-20">Todo not found</div>
    );
  }

  return (
    <div className="pt-2 space-y-6">
      <div className="">
        <button
          onClick={() => navigate('/todo')}
          className="text-gray-500 flex items-center space-x-1 hover:text-gray-700"
        >
          <IoArrowBackOutline />
          <span className="text-sm">Back</span>
        </button>
        <h2 className="text-2xl font-bold">Todo Details</h2>
      </div>
      <div className="mt-6 bg-white border shadow-xl rounded-lg p-6 space-y-6">
        <FieldEditor
          label="Title"
          value={todo.title}
          fieldKey="title"
          todoId={todo.id}
        />
        <FieldEditor
          label="Description"
          value={todo.description}
          type="textarea"
          fieldKey="description"
          todoId={todo.id}
        />
        <FieldEditor
          label="Due Date"
          value={todo.dueDate}
          type="date"
          fieldKey="dueDate"
          todoId={todo.id}
        />
        <FieldEditor
          label="Priority"
          value={todo.priority}
          type="select"
          options={['low', 'medium', 'high']}
          fieldKey="priority"
          todoId={todo.id}
        />
      </div>
    </div>
  );
};
