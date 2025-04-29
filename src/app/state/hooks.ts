import { useRecoilCallback } from 'recoil';
import { todoListState, Todo } from './todo.state';

export function useUpdateTodo() {
  return useRecoilCallback(({ set }) => (id: number, newData: Partial<Todo>) => {
    set(todoListState, (todos) =>
      todos.map((todo) =>
        todo.id === id ? { ...todo, ...newData } : todo
      )
    );
  }, []);
}
