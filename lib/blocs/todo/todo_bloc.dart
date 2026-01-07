import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo/blocs/todo/todo_event.dart';
import 'package:todo/blocs/todo/todo_state.dart';
import 'package:todo/data/models/todo.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TodoBloc() : super(TodoInitial()) {
    on<LoadTodos>((event, emit) async {
      emit(TodoLoadInProgress());
      try {
        final snapshot = await _firestore.collection('todos').get();
        final todos = snapshot.docs.map((doc) {
          final todo = Todo.fromJson(doc.data());

          todo.id = doc.id;
          return todo;
        }).toList();
        emit(TodoLoadSuccess(todos));
      } catch (e) {
        emit(TodoLoadFailure(e.toString()));
      }
    });

    on<DeleteTodo>((event, emit) async {
      try {
        await _firestore.collection('todos').doc(event.todoId).delete();
        add(LoadTodos());
      } catch (e) {
        emit(TodoLoadFailure(e.toString()));
      }
    });

    on<ToggleTodoStatus>((event, emit) async {
      try {
        await _firestore.collection('todos').doc(event.todoId).update({
          'status': event.isCompleted ? 'Completed' : 'Pending',
        });
        add(LoadTodos());
      } catch (e) {
        emit(TodoLoadFailure(e.toString()));
      }
    });
  }
}
