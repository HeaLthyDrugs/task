import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/data/database.dart';
import 'package:todo_app/util/todo_tile.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _myBox = Hive.box('myBox');
  ToDoDatabase db = ToDoDatabase();

  late TabController _tabController;

  @override
  void initState() {
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final _controller = TextEditingController();

  List toDoList = [
    ["Make nigga recipe", false],
    ["Buy groceries", false],
    ["Make dinner", false],
    ["Go to gym nigga", false],
    ["Learn flutter", false],
    ["Take a shower", false],
    ["Clean house", false],
    ["Exercise", false],
    ["Eat healthy", false],
    ["Sleep well", false],
    ["Learn to speak Spanish", false],
  ];

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateData();
  }

  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateData();
  }

  void saveNewTask() {
    setState(() {
      db.toDoList.add([_controller.text, false]);
      _controller.clear();
    });
    db.updateData();
  }

  void createNewTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Add a new task',
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                      style: ElevatedButton.styleFrom(),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        saveNewTask();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = db.toDoList.removeAt(oldIndex);
      db.toDoList.insert(newIndex, item);
    });
    db.updateData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          title: Text(
            'Task',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
          ),
          // centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Ongoing'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewTask,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTaskList(false),
            _buildTaskList(true),
          ],
        ));
  }

  Widget _buildTaskList(bool isCompleted) {
    final filteredList =
        db.toDoList.where((task) => task[1] == isCompleted).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Lottie.asset(
                'assets/animations/ghost.json',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20),
              Text(
                isCompleted ? 'No completed tasks yet' : 'No ongoing tasks',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        return TodoTile(
          key: ValueKey(filteredList[index]),
          taskName: filteredList[index][0],
          taskCompleted: filteredList[index][1],
          onChanged: (value) =>
              checkBoxChanged(value, db.toDoList.indexOf(filteredList[index])),
          deleteFunction: (context) =>
              deleteTask(db.toDoList.indexOf(filteredList[index])),
          index: index,
        );
      },
      onReorder: (oldIndex, newIndex) {
        final globalOldIndex = db.toDoList.indexOf(filteredList[oldIndex]);
        final globalNewIndex = db.toDoList.indexOf(filteredList[newIndex]);
        onReorder(globalOldIndex, globalNewIndex);
      },
    );
  }
}
