import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/data/database.dart';
import 'package:todo_app/helper/notification_helper.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/pages/splash.dart';
import 'package:todo_app/theme/theme.dart';
import 'package:todo_app/theme/theme_provider.dart';
import 'package:todo_app/util/todo_tile.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart'; // Add this import

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

  void _migrateExistingTasks() {
    bool needsMigration = false;
    for (int i = 0; i < db.toDoList.length; i++) {
      if (db.toDoList[i].length < 3) {
        db.toDoList[i] = [
          db.toDoList[i][0],
          db.toDoList[i][1],
          DateTime.now(), // Add a default datetime
        ];
        needsMigration = true;
      }
    }
    if (needsMigration) {
      db.updateData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final _controller = TextEditingController();

  List toDoList = [
    ["Make nigga recipe", false, null],
    ["Buy groceries", false, null],
    ["Make dinner", false, null],
    ["Go to gym nigga", false, null],
    ["Learn flutter", false, null],
    ["Take a shower", false, null],
    ["Clean house", false, null],
    ["Exercise", false, null],
    ["Eat healthy", false, null],
    ["Sleep well", false, null],
    ["Learn to speak Spanish", false, null],
  ];

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateData();
  }

  void deleteTask(int index) async {
    final task = db.toDoList[index];
    final notificationId = task.length > 3 ? task[3] : null;

    if (notificationId != null) {
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    }

    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateData();
  }

  void saveNewTask() async {
    try {
      int? notificationId;
      if (_selectedDateTime != null) {
        notificationId = await NotificationHelper.scheduleNotification(
          '⏰ Task Reminder',
          _controller.text,
          _selectedDateTime!,
        );
      }

      setState(() {
        db.addTask(_controller.text, _selectedDateTime, notificationId);
        _controller.clear();
        _selectedDateTime = null;
      });
      db.updateData();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task added successfully')),
      );
    } catch (e) {
      print('Error saving task: $e');
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add task: $e')),
      );
    }
  }

  // Create a new task

  void createNewTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                      maxLines: 3,
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Add task',
                        hintStyle: TextStyle(
                            color: Colors.grey, fontFamily: 'Montserrat'),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await _selectDateTime(context);
                            setState(() {}); // Update the UI
                          },
                          child: Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 24, color: Colors.grey),
                              SizedBox(width: 8),
                              Text(
                                _selectedDateTime != null
                                    ? DateFormat('MMM d, y HH:mm')
                                        .format(_selectedDateTime!)
                                    : '',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            saveNewTask();
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.green.shade400,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.add_task_rounded,
                                color: Colors.green.shade400,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // New button for navigating to Splash screen
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex--;
      }
      final item = db.toDoList.removeAt(oldIndex);
      db.toDoList.insert(newIndex, item);
    });
    db.updateData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Task',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                fontSize: 30,
                fontFamily: 'Montserrat'),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          actions: [
            IconButton(
              icon: Icon(
                Provider.of<ThemeProvider>(context).getTheme() == lightMode
                    ? Icons.dark_mode
                    : Icons.light_mode,
                size: 20,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme();
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).colorScheme.onPrimary,
            indicatorWeight: 2,
            labelStyle: TextStyle(fontFamily: 'Montserrat'),
            dividerColor: Theme.of(context).colorScheme.surface,
            unselectedLabelColor: Theme.of(context).colorScheme.onPrimary,
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
            color: Theme.of(context).colorScheme.surface,
          ),
          backgroundColor: Theme.of(context).colorScheme.onSurface,
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

    // Reorderable list view
    return ReorderableListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final task = filteredList[index];
        final DateTime? taskDateTime = task.length > 2 ? task[2] : null;

        return TodoTile(
          key: ValueKey(db.toDoList
              .indexOf(task)), // Use the index in the original list as the key
          taskName: task[0],
          taskCompleted: task[1],
          taskDateTime: taskDateTime,
          onChanged: (value) =>
              checkBoxChanged(value, db.toDoList.indexOf(task)),
          deleteFunction: (context) => deleteTask(db.toDoList.indexOf(task)),
          index: index,
        );
      },
      onReorder: onReorder,
    );
  }

  // Select date and time
  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          DateTime selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          // Ensure the selected time is in the future
          if (selectedDateTime.isBefore(DateTime.now())) {
            selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
          }

          _selectedDateTime = selectedDateTime;
        });
      }
    }
  }

  DateTime? _selectedDateTime;
}
