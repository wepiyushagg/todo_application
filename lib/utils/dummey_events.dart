
import 'package:event_logger/event_logger.dart';

class DummeyEvents{

  final newTodo = {
  'title': "new",
  'shortDescription': "DEF",
  'longDescription': "GHI",
  'priority': "LOW",
  'status': true,
  };

  final updateTodo = {
    'title': "update",
    'shortDescription': "DEF",
    'longDescription': "GHI",
    'priority': "LOW",
    'status': true,
  };

  final deleteTodo = {
    'title': "update",
    'shortDescription': "DEF",
    'longDescription': "GHI",
    'priority': "LOW",
    'status': true,
  };

  Future<void> event1() async {
    await EventLoggerService().logEvent(
      eventName: 'add_todo',
      fromScreen: 'AddTodoListScreen',
      toScreen: 'HomeScreen',
      metadata: newTodo,
    );
  }

  Future<void> event2() async {
    await EventLoggerService().logEvent(
      eventName: 'update_todo',
      fromScreen: 'AddTodoListScreen',
      toScreen: 'HomeScreen',
      metadata: updateTodo,
    );
  }


  Future<void> event3() async {
    await EventLoggerService().logEvent(
      eventName: 'delete_todo',
      fromScreen: 'AddTodoListScreen',
      toScreen: 'HomeScreen',
      metadata: deleteTodo,
    );
  }

  Future<void> event4() async {
  }





}