import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo/blocs/todo/todo_bloc.dart';
import 'package:todo/blocs/todo/todo_event.dart';
import 'package:todo/blocs/todo/todo_state.dart';
import 'package:todo/data/models/todo.dart';
import 'package:todo/domain/constant/appcolors.dart';
import 'package:todo/repository/screens/addtodolist/addtask.dart';
import 'package:todo/repository/screens/detaileddescription/taskdetails.dart';
import 'package:todo/repository/screens/edittask/edittask.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: BlocProvider(
        create: (context) => TodoBloc()..add(LoadTodos()),
        child: const TodoList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTodoListScreen(),
            ),
          );
        },
        label: const Text('+ Add'),
      ),
    );
  }
}

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        if (state is TodoLoadInProgress) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TodoLoadSuccess) {
          final todos = state.todos;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return TodoListItem(todo: todo);
            },
          );
        } else if (state is TodoLoadFailure) {
          return Center(child: Text('Failed to load todos: ${state.error}'));
        } else {
          return const Center(child: Text('No todos found'));
        }
      },
    );
  }
}

class TodoListItem extends StatelessWidget {
  const TodoListItem({
    super.key,
    required this.todo,
  });

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 10,
      color: AppColors.listcolor,
      child: InkWell(
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailedDescriptionScreen(
                todoId: todo.id,
              ),
            ),
          );
        },
        child: ListTile(
          leading: PriorityChip(priority: todo.priority),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  todo.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                todo.status,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: todo.status == 'Completed'
                      ? Colors.amberAccent
                      : Colors.lightBlueAccent,
                ),
              ),
            ],
          ),
          subtitle: Text(
            todo.dueDate != null ? 'Due: ${DateFormat.yMd().add_jm().format(todo.dueDate!)}' : 'No due date',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF22577A),
            ),
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditTodoScreen(
                      todoId: todo.id,
                      todoData: todo.toJson(),
                    ),
                  ),
                );
              } else if (value == 'delete') {
                showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('Delete Todo'),
                      content: const Text(
                        'Are you sure you want to delete this todo?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<TodoBloc>().add(DeleteTodo(todo.id));
                            Navigator.pop(dialogContext);
                          },
                          child: const Text(
                            'Yes',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else if (value == 'toggleStatus') {
                context.read<TodoBloc>().add(
                      ToggleTodoStatus(
                        todoId: todo.id,
                        isCompleted: todo.status != 'Completed',
                      ),
                    );
              }
            },
            itemBuilder: (context) => [

              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'toggleStatus',
                child: Text(
                  todo.status == 'Completed'
                      ? 'Mark as Pending'
                      : 'Mark as Completed',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, this.priority});

  final String? priority;

  @override
  Widget build(BuildContext context) {
    final Color color;

    switch (priority) {
      case 'High':
        color = Colors.red;
        break;
      case 'Medium':
        color = Colors.orange;
        break;
      case 'Low':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      width: 20.0,
      height: 20.0,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
