import { atom, selector, selectorFamily } from 'recoil';

export type Priority = 'low' | 'medium' | 'high';

export interface Todo {
  id: number;
  title: string;
  description?: string;
  dueDate?: string;
  createdAt: number;
  completed: boolean;
  priority?: Priority;
}

const defaultTodos: Todo[] = [
  {
    id: 1,
    title: 'Buy groceries',
    description: 'Milk, bread, eggs, and cheese',
    dueDate: '2025-05-01',
    createdAt: Date.now() - 86400000,
    completed: false,
    priority: 'medium',
  },
  {
    id: 2,
    title: 'Finish project report',
    description: 'Write summary and conclusion sections',
    dueDate: '2025-04-30',
    createdAt: Date.now() - 2 * 86400000,
    completed: false,
    priority: 'high',
  },
  {
    id: 3,
    title: 'Call mom',
    createdAt: Date.now() - 3 * 86400000,
    completed: true,
    priority: 'low',
  },
];

export const todoListState = atom<Todo[]>({
  key: 'todoListState',
  default: defaultTodos,
});

export const todoCountState = selector<number>({
  key: 'todoCountState',
  get: ({ get }) => get(todoListState).length,
});


export const todoByIdState = selectorFamily<Todo | undefined, number>({
  key: 'todoByIdState',
  get: (id: number) => ({ get }) => {
    const todos = get(todoListState);
    return todos.find((todo) => todo.id === id);
  },
});