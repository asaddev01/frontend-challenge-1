import { useRecoilState } from 'recoil';
import { todoListState } from '../state/todo.state';
import { TodoItem } from './TodoItem';

export const TodoList = () => {
  const [todos] = useRecoilState(todoListState);

  return (
    <ul className="space-y-3 mb-2">
      {todos.map((todo) => (
        <TodoItem key={todo.id} todo={todo} />
      ))}
    </ul>
  );
};
