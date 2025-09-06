import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String id;
  final String title;
  final bool isDone;
  final DateTime? dueDate;

  Todo({
    required this.id,
    required this.title,
    this.isDone = false,
    this.dueDate,
  });

  factory Todo.fromMap(String id, Map<String, dynamic> data) {
    return Todo(
      id: id,
      title: data['title'] ?? '',
      isDone: data['isDone'] ?? false,
      dueDate: data['dueDate'] != null ? (data['dueDate'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isDone': isDone,
      'dueDate': dueDate,
    };
  }
}
