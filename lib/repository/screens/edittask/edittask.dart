import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_logger/event_logger.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditTodoScreen extends StatefulWidget {
  final String todoId;
  final Map<String, dynamic> todoData;

  const EditTodoScreen({
    super.key,
    required this.todoId,
    required this.todoData,
  });

  @override
  State<EditTodoScreen> createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _shortdescriptionController;
  late TextEditingController _longdescriptionController;

  late String _priority;
  late String _status;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todoData['title'] ?? '');
    _shortdescriptionController =
        TextEditingController(text: widget.todoData['shortDescription'] ?? '');
    _longdescriptionController =
        TextEditingController(text: widget.todoData['longDescription'] ?? '');
    _priority = widget.todoData['priority'] ?? 'Medium';
    _status = widget.todoData['status'] ?? 'Pending';
    if (widget.todoData['dueDate'] != null) {
      try {
        _dueDate = DateFormat("MMMM d, yyyy 'at' h:mm:ss a 'UTC'ZZZZ")
            .parse(widget.todoData['dueDate']);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _shortdescriptionController.dispose();
    _longdescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate != null) {
      setState(() {
        final time = _dueDate != null
            ? TimeOfDay.fromDateTime(_dueDate!)
            : const TimeOfDay(hour: 0, minute: 0);

        _dueDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _pickDueTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime:
          _dueDate != null ? TimeOfDay.fromDateTime(_dueDate!) : TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        final date = _dueDate ?? DateTime.now();

        _dueDate = DateTime(
          date.year,
          date.month,
          date.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _update() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    try {
    final updateTodo = {
      'title': _titleController.text.trim(),
    'shortDescription': _shortdescriptionController.text.trim(),
    'longDescription': _longdescriptionController.text.trim(),
    'priority': _priority,
    'status': _status,
    'dueDate': _dueDate?.toUtc().toIso8601String(),
    };

    await FirebaseFirestore.instance
        .collection('todos')
        .doc(widget.todoId)
        .update(updateTodo);



      await EventLoggerService().logEvent(
        eventName: 'update_todo',
        fromScreen: 'AddTodoListScreen',
        toScreen: 'HomeScreen',
        metadata: updateTodo,
      );

    if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('To-Do updated successfully')),
        );
        Navigator.pop(context);
    }
    } catch (e) {
      print('Error updating todo: $e');
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update To-Do')),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit To-Do'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Enter a title' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _shortdescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Short Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _longdescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Long Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _priority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'High',
                        child: Row(
                          children: [
                            CircleAvatar(radius: 12, backgroundColor: Colors.red),
                            SizedBox(width: 8),
                            Text('High'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Medium',
                        child: Row(
                          children: [
                            CircleAvatar(
                                radius: 12, backgroundColor: Colors.orange),
                            SizedBox(width: 8),
                            Text('Medium'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Low',
                        child: Row(
                          children: [
                            CircleAvatar(
                                radius: 12, backgroundColor: Colors.green),
                            SizedBox(width: 8),
                            Text('Low'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _priority = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Completed',
                        child: Row(
                          children: [
                            CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.amberAccent),
                            SizedBox(width: 8),
                            Text('Completed'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Pending',
                        child: Row(
                          children: [
                            CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.lightBlueAccent),
                            SizedBox(width: 8),
                            Text('Pending'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _status = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _pickDueDate,
                          child: Text(
                            _dueDate == null
                                ? 'Select due date'
                                : 'Due: ${_dueDate!.toLocal().toString().split(' ')[0]}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _pickDueTime,
                          child: Text(
                            _dueDate == null
                                ? 'Select due time'
                                : 'Time: ${TimeOfDay.fromDateTime(_dueDate!).format(context)}',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _update,
                    child: const Text('Update'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}