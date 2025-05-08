import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      theme: ThemeData( colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),),
      home: TodoHomepage(),
    );
  }
}
class TodoItem{
  String title;
  bool isDone;
  TodoItem({required this.title, this.isDone = false});
}

class TodoHomepage extends StatefulWidget{
  const TodoHomepage({super.key});

  @override
  _TodoHomePageState createState() =>_TodoHomePageState();

}

class _TodoHomePageState extends State<TodoHomepage>{
  final TextEditingController _controller =TextEditingController();
  final List<TodoItem> _todoItems = [];

   void _addTodo(){
    if(_controller.text.isNotEmpty){
      setState(() {
        _todoItems.add(TodoItem(title: _controller.text));
        _controller.clear();
      });
    }
   }

   void _removeTodo(int index){
    setState(() {
      _todoItems.removeAt(index);
    });
   }

   void _toggleComplete(int index){
    setState(() {
      _todoItems[index].isDone = !_todoItems[index].isDone;
    });
   }

   @override
  Widget build(BuildContext context) {
    // UI
    return Scaffold(
      appBar: AppBar(
        title:Center(child: Text('My ToDo List',style:GoogleFonts.roboto(
    fontSize: 30,
    fontWeight: FontWeight.w400,
  ),)),
        backgroundColor: const Color.fromARGB(255, 241, 203, 248),
      ),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.all(12.0),
          child: Row(
            children: [
            Expanded(child: TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: 'Enter a new todo item'),
            )),
            ElevatedButton(
            onPressed: _addTodo,
            style: ElevatedButton.styleFrom(foregroundColor: Colors.black,
            backgroundColor:Colors.amber ),
             child: Text('ADD'),)
          ],
          ),
          ),
          Expanded(
             child: ListView.builder(
              itemCount:_todoItems.length,
              itemBuilder: (context, index) {
                final item =_todoItems[index];
                return Container( 
                  color: index % 2 == 0 ? Colors.lightBlue[50] : Colors.white,
        
                  child: ListTile(
                    leading: Checkbox(value: item.isDone, onChanged: (_)=> _toggleComplete(index),
                    ),
                    title: Text(item.title,
                    style: TextStyle(decoration: item.isDone ? TextDecoration.lineThrough:null,),
                    ),
                    trailing: IconButton(onPressed: ()=> _removeTodo(index), icon: Icon(Icons.delete),
                    style: IconButton.styleFrom(backgroundColor: Colors.red,foregroundColor: Colors.black),),
                  ),
                );
              },
                       ),
           )
          
        ],
      ),
    );
  }
}
