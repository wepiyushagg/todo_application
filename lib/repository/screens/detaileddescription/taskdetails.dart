import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DetailedDescriptionScreen extends StatelessWidget {
  final String todoId;

  const DetailedDescriptionScreen({
    super.key,
    required this.todoId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('todos').doc(todoId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Todo not found'));
          }

          final todoData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todoData['title'] ?? 'No Title',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (todoData['shortDescription'] != null &&
                    todoData['shortDescription'].toString().isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Task Summary: ',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        todoData['shortDescription'],
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                if (todoData['longDescription'] != null &&
                    todoData['longDescription'].toString().isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Task Description: ',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        todoData['longDescription'],
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                const SizedBox(height: 40),
                if (todoData['priority'] != null)
                  Row(
                    children: [
                      const Text(
                        'Priority: ',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        todoData['priority'],
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                const SizedBox(height: 5),
                if (todoData['status'] != null)
                  Row(
                    children: [
                      const Text(
                        'Status: ',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        todoData['status'],
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                const SizedBox(height: 5),
                if (todoData['dueDate'] != null)
                  Row(
                    children: [
                      const Text(
                        'Due Date: ',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatDateTimeFromString(todoData['dueDate'], context),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String formatDateTimeFromString(String dateString, BuildContext context) {
  try {
    var sanitizedDateString = dateString.replaceFirstMapped(
        RegExp(r'UTC([+-])(\d):(\d\d)'),
        (match) => 'UTC${match.group(1)}0${match.group(2)}:${match.group(3)}');

    final DateTime date = DateFormat(
      "MMMM d, yyyy 'at' h:mm:ss a 'UTC'ZZZZ",
    ).parse(sanitizedDateString);

    final String time = TimeOfDay.fromDateTime(date).format(context);

    return '${date.day}/${date.month}/${date.year} • $time';
  } catch (e) {
    print('Error parsing date: $e');
    return dateString;
  }
}
