import 'package:hive_flutter/hive_flutter.dart';

class ToDoDatabase {
  final _myBox = Hive.box('myBox');

  List toDoList = [];

  void createInitialData() {
    toDoList = [
      ["Make Tutorial", false, DateTime.now(), null],
      ["Do Exercise", false, DateTime.now(), null],
    ];
  }

  void loadData() {
    toDoList = _myBox.get('TODOLIST');
  }

  void updateData() {
    _myBox.put('TODOLIST', toDoList);
  }

  void addTask(
      String taskName, DateTime? scheduledDateTime, int? notificationId) {
    toDoList.add([taskName, false, scheduledDateTime, notificationId]);
    updateData();
  }

  void updateTaskNotificationId(int taskIndex, int notificationId) {
    if (taskIndex >= 0 && taskIndex < toDoList.length) {
      toDoList[taskIndex][3] = notificationId;
      updateData();
    }
  }
}
