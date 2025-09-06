import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/model/todo_model.dart';


class FirestoreService {
  final CollectionReference todosRef =
      FirebaseFirestore.instance.collection('todos');

  Stream<List<Todo>> getTodos() {
    return todosRef.orderBy('timestamp', descending: true).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return Todo.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();
      },
    );
  }

  Future<void> addTodo(Todo todo) async {
    await todosRef.add({
      ...todo.toMap(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleTodo(String id, bool isDone) async {
    await todosRef.doc(id).update({'isDone': !isDone});
  }

  Future<void> deleteTodo(String id) async {
    await todosRef.doc(id).delete();
  }
}
