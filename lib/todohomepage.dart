import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/todo_model.dart';
import 'package:flutter_application_1/services/firestoreservices.dart';
import 'package:google_fonts/google_fonts.dart';
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

  void _toggleComplete(Todo todo) async {
    await _firestoreService.toggleTodo(todo.id, todo.isDone);
  }

  void _removeTodo(String id) async {
    await _firestoreService.deleteTodo(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.withOpacity(.2), 
      appBar: AppBar( backgroundColor: Colors.brown.withOpacity(.2),  
  elevation: 0,
        title: Center(
          child: Text(
            'My ToDo',
            style: GoogleFonts.roboto(
              color: Colors.brown.shade800,  
              fontSize: 30,
              fontWeight: FontWeight.w800, 
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter a new todo item',
                      filled: true,
                      fillColor: Colors.white.withOpacity(.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _pickDateTime,
                  icon: const Icon(Icons.calendar_today),
                  color: Colors.brown[700],
                ),
                ElevatedButton(
                  onPressed: _addTodo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown, 
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('ADD'),
                ),
              ],
            ),
          ),

          if (_selectedDateTime != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Due: ${DateFormat('dd/MM/yyyy hh:mm a').format(_selectedDateTime!)}",
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

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
                    child: Text(
                      "No tasks yet. Add some!",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: index % 2 == 0
                            ? Colors.brown.withOpacity(.15)
                            : Colors.brown.withOpacity(.08),  
                        borderRadius: BorderRadius.circular(15), 
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Checkbox(
                          value: todo.isDone,
                          onChanged: (_) => _toggleComplete(todo),
                          activeColor: Colors.brown,
                        ),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold, 
                            decoration:
                                todo.isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: todo.dueDate != null
                            ? Text(
                                "Due: ${DateFormat('dd/MM/yyyy hh:mm a').format(todo.dueDate!)}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              )
                            : const Text("No deadline"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeTodo(todo.id),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
