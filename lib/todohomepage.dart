import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/todo_model.dart';
import 'package:flutter_application_1/services/firestoreservices.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;

import 'package:intl/intl.dart';


class TodoHomepage extends StatefulWidget {
  const TodoHomepage({super.key});

  @override
  State<TodoHomepage> createState() => _TodoHomepageState();
}

class _TodoHomepageState extends State<TodoHomepage> {
  final TextEditingController _controller = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  DateTime? _selectedDateTime;

  /// Pick Date & Time
  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (!mounted) return;

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (!mounted) return;

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  /// Add new Todo
  void _addTodo() async {
    if (_controller.text.isEmpty) return;

    final todo = Todo(
      id: '',
      title: _controller.text,
      isDone: false,
      dueDate: _selectedDateTime,
    );

    await _firestoreService.addTodo(todo);

    _controller.clear();
    setState(() {
      _selectedDateTime = null;
    });
  }

  /// Toggle complete
  void _toggleComplete(Todo todo) async {
    await _firestoreService.toggleTodo(todo.id, todo.isDone);
  }

  /// Delete Todo
  void _removeTodo(String id) async {
    await _firestoreService.deleteTodo(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'My ToDo List',
            style: GoogleFonts.roboto(
              fontSize: 30,
              fontWeight: FontWeight.w400,
              foreground: Paint()
                ..shader = ui.Gradient.linear(
                  const Offset(0, 20),
                  const Offset(150, 20),
                  const [
                    Color.fromARGB(255, 244, 200, 54),
                    Color.fromARGB(255, 233, 90, 33),
                  ],
                ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Input field + buttons
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter a new todo item',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _pickDateTime,
                  icon: const Icon(Icons.calendar_today),
                  color: Colors.blue,
                ),
                ElevatedButton(
                  onPressed: _addTodo,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.amber,
                  ),
                  child: const Text('ADD'),
                ),
              ],
            ),
          ),

          // Show picked Date & Time (before saving)
          if (_selectedDateTime != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Due: ${DateFormat('dd/MM/yyyy hh:mm a').format(_selectedDateTime!)}",
                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ),

          // Todo List
          Expanded(
            child: StreamBuilder<List<Todo>>(
              stream: _firestoreService.getTodos(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final todos = snapshot.data!;

                if (todos.isEmpty) {
                  return const Center(
                    child: Text("No tasks yet. Add some!"),
                  );
                }

                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];

                    return Container(
                      color: index % 2 == 0 ? Colors.lightBlue[50] : Colors.white,
                      child: ListTile(
                        leading: Checkbox(
                          value: todo.isDone,
                          onChanged: (_) => _toggleComplete(todo),
                        ),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            decoration: todo.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: todo.dueDate != null
                            ? Text(
                                "Due: ${DateFormat('dd/MM/yyyy hh:mm a').format(todo.dueDate!)}")
                            : const Text("No deadline"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeTodo(todo.id),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
