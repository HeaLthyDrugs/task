import 'package:hive_flutter/hive_flutter.dart';

class ToDoDatabase {
  final _myBox = Hive.box('myBox');

  List toDoList = [];

  void createInitialData() {
    toDoList = [
      ["Make Tutorial", false, DateTime.now()],
      ["Do Exercise", false, DateTime.now()],
    ];
  }

  void loadData() {
    toDoList = _myBox.get('TODOLIST');
  }

  void updateData() {
    _myBox.put('TODOLIST', toDoList);
  }
}
