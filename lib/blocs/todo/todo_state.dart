import 'package:equatable/equatable.dart';
import 'package:todo/data/models/todo.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoadInProgress extends TodoState {}

class TodoLoadSuccess extends TodoState {
  final List<Todo> todos;

  const TodoLoadSuccess(this.todos);

  @override
  List<Object> get props => [todos];
}

class TodoLoadFailure extends TodoState {
  final String error;

  const TodoLoadFailure(this.error);

  @override
  List<Object> get props => [error];
}

class NavigateToAddTaskScreen extends TodoState {}

class NavigateToTaskDetailScreen extends TodoState {
  final String todoId;

  const NavigateToTaskDetailScreen(this.todoId);

  @override
  List<Object> get props => [todoId];
}

class NavigateToEditTaskScreen extends TodoState {
  final Todo todo;

  const NavigateToEditTaskScreen(this.todo);

  @override
  List<Object> get props => [todo];
}
