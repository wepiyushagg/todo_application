import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  late String id;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String longDescription;
  final String priority;
  final String shortDescription;
  final String status;
  final String title;

  Todo({
    required this.createdAt,
    this.dueDate,
    required this.longDescription,
    required this.priority,
    required this.shortDescription,
    required this.status,
    required this.title,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      createdAt: _toDateTime(json['createdAt']) ?? DateTime.now(),
      dueDate: _toDateTime(json['dueDate']),
      longDescription: json['longDescription'] ?? '',
      priority: json['priority'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      status: json['status'] ?? '',
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'longDescription': longDescription,
      'priority': priority,
      'shortDescription': shortDescription,
      'status': status,
      'title': title,
    };
  }

  static DateTime? _toDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return null;
  }
}
