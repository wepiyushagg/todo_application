import 'package:flutter/material.dart';
import 'package:todo/utils/dummey_events.dart';

class EventHomeScreen extends StatelessWidget {
  const EventHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyEvent = DummeyEvents();
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: Column(
        children: [
          TextButton(onPressed: () {dummyEvent.event1();}, child: Text(("ADD"))),
          TextButton(onPressed: () {dummyEvent.event2();}, child: Text(("UPDATE"))),
          TextButton(onPressed: () {dummyEvent.event3();}, child: Text(("DELETE"))),
          TextButton(onPressed: () {dummyEvent.event1();}, child: Text(("ADD"))),
          TextButton(onPressed: () {dummyEvent.event2();}, child: Text(("UPDATE"))),
          TextButton(onPressed: () {dummyEvent.event3();}, child: Text(("DELETE"))),
        ],
      ),
    );
  }
}
