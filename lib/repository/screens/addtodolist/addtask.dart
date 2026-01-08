import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_logger/event_logger.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/repository/screens/home/homescreen.dart';

class AddTodoListScreen extends StatefulWidget {
  const AddTodoListScreen({super.key});

  @override
  State<AddTodoListScreen> createState() => _AddTodoListScreenState();
}

class _AddTodoListScreenState extends State<AddTodoListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _shortdescriptionController = TextEditingController();
  final _longdescriptionController = TextEditingController();

  String _priority = 'Medium';
  final String _status = 'Pending';
  DateTime? _dueDate;

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
      initialTime: _dueDate != null
          ? TimeOfDay.fromDateTime(_dueDate!)
          : TimeOfDay.now(),
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

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final createdAtString =
        DateFormat("MMMM d, yyyy 'at' h:mm:ss a 'UTC'Z").format(now.toUtc());
    final String? dueDateString = _dueDate != null
        ? DateFormat("MMMM d, yyyy 'at' h:mm:ss a 'UTC'Z")
            .format(_dueDate!.toUtc())
        : null;

    try {
      final newTodo = {
        'title': _titleController.text.trim(),
        'shortDescription': _shortdescriptionController.text.trim(),
        'longDescription': _longdescriptionController.text.trim(),
        'priority': _priority,
        'dueDate': dueDateString,
        'status': _status,
        'createdAt': createdAtString,
      };

      await FirebaseFirestore.instance.collection('todos').add(newTodo);

      await EventLoggerService().logEvent(
        eventName: 'add_todo',
        fromScreen: 'AddTodoListScreen',
        toScreen: 'HomeScreen',
        metadata: newTodo,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('To-Do saved successfully')),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print('Error saving todo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save To-Do')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add To-Do'),
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
                    initialValue: _priority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'High',
                        child: Row(
                          children: [
                            CircleAvatar(
                                radius: 12, backgroundColor: Colors.red),
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
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _formKey.currentState!.reset();
                            _titleController.clear();
                            _shortdescriptionController.clear();
                            _longdescriptionController.clear();
                            setState(() {
                              _dueDate = null;
                              _priority = 'Medium';
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: const Text('Save'),
                        ),
                      ),
                    ],
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
