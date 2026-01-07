import 'package:equatable/equatable.dart';
import 'package:todo/data/models/todo.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object> get props => [];
}

class LoadTodos extends TodoEvent {}

class DeleteTodo extends TodoEvent {
  final String todoId;

  const DeleteTodo(this.todoId);

  @override
  List<Object> get props => [todoId];
}

class ViewTodo extends TodoEvent {
  final String todoId;

  const ViewTodo(this.todoId);

  @override
  List<Object> get props => [todoId];
}

class ToggleTodoStatus extends TodoEvent {
  final String todoId;
  final bool isCompleted;

  const ToggleTodoStatus({required this.todoId, required this.isCompleted});

  @override
  List<Object> get props => [todoId, isCompleted];
}

class AddTodo extends TodoEvent {}

class EditTodo extends TodoEvent {
  final Todo todo;

  const EditTodo(this.todo);

  @override
  List<Object> get props => [todo];
}
