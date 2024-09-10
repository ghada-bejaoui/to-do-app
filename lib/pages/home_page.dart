import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:todo_app_flutter/utils/database_helper.dart';
import 'package:todo_app_flutter/utils/todo_list.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  Color _selectedColor = Colors.deepPurple; // Couleur par défaut
  List<Map<String, dynamic>> toDoList = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

void loadData() async {
  final dbHelper = DatabaseHelper();
  final tasks = await dbHelper.getTasks();
  setState(() {
    toDoList = tasks.map((task) {
      return {
        'id': task['id'],
        'name': task['name'],
        'isCompleted': task['isCompleted'] == 1,
        'position': task['position'],
        'color': Color(task['color']),
      };
    }).toList();
  });
}


void saveNewTask() async {
  final dbHelper = DatabaseHelper();
  if (_controller.text.isNotEmpty) {
    await dbHelper.insertTask(_controller.text, false, _selectedColor.value);
    _controller.clear();
    setState(() {
      _selectedColor = Colors.deepPurple; // Réinitialiser la couleur sélectionnée
    });
    loadData(); // Recharge les données après ajout
  }
}

  void checkBoxChanged(int index) async {
    final dbHelper = DatabaseHelper();
    bool newStatus = !toDoList[index]['isCompleted'];
    await dbHelper.updateTask(toDoList[index]['id'], newStatus);
    setState(() {
      toDoList[index]['isCompleted'] = newStatus;
    });
  }

void deleteTask(int index) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteTask(toDoList[index]['id']);
    setState(() {
      toDoList.removeAt(index);
      // Mettre à jour les positions des éléments restants
      for (int i = 0; i < toDoList.length; i++) {
        toDoList[i]['position'] = i;
        dbHelper.updateTaskPosition(toDoList[i]['id'], i);
      }
    });
  }

void onReorder(int oldIndex, int newIndex) async {
  final dbHelper = DatabaseHelper();

  if (oldIndex < newIndex) {
    newIndex -= 1;
  }

  final movedTask = toDoList.removeAt(oldIndex);
  toDoList.insert(newIndex, movedTask);

  // Mettre à jour les positions des éléments après réorganisation
  for (int i = 0; i < toDoList.length; i++) {
    toDoList[i]['position'] = i;
    await dbHelper.updateTaskPosition(toDoList[i]['id'], i);
  }

  setState(() {});
}

  void _selectColor() async {
    Color? color = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              showLabel: false,
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(_selectedColor);
              },
            ),
          ],
        );
      },
    );

    if (color != null) {
      setState(() {
        _selectedColor = color;
      });
    }
  }



@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.deepPurple.shade300,
    appBar: AppBar(
      title: const Text(
        'Wish List ❤️',
      ),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
    body: Column(
      children: [
        Expanded(
          child: toDoList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center, 
                    children: [
                      Text(
                        'Add your dreams and make them come true! 🪄',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    
                    ],
                  ),
                )
              : ReorderableListView(
                  onReorder: onReorder,
                  children: [
                    for (int i = 0; i < toDoList.length; i++)
                      TodoList(
                        key: ValueKey(toDoList[i]['id']),
                        taskId: toDoList[i]['id'],
                        taskName: toDoList[i]['name'],
                        taskCompleted: toDoList[i]['isCompleted'],
                        backgroundColor: toDoList[i]['color'],
                        onChanged: (value) => checkBoxChanged(i),
                        deleteFunction: (context) => deleteTask(i),
                        position: toDoList[i]['position'],
                      ),
                  ],
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 5
            ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '💫What do u wish for?',
                      filled: true,
                      fillColor: Colors.deepPurple.shade200,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.deepPurple,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.deepPurple,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.color_lens),
                onPressed: _selectColor,
              ),
              FloatingActionButton(
                onPressed: saveNewTask,
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


}
