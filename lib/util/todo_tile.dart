import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart'; // Add this import

class TodoTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final DateTime? taskDateTime;
  Function(bool?)? onChanged;
  Function(BuildContext)? deleteFunction;
  final int index;

  TodoTile({
    required Key key, // Add this line
    required this.taskName,
    required this.taskCompleted,
    this.taskDateTime,
    required this.onChanged,
    required this.deleteFunction,
    required this.index,
  }) : super(key: key); // Add this line

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 1.0, top: 1.0, right: 1.0, bottom: 1.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: StretchMotion(),
          children: [
            SlidableAction(
              onPressed: deleteFunction,
              icon: Icons.delete,
              backgroundColor: Colors.red.shade300,
              borderRadius: BorderRadius.circular(12),
            )
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(17),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Icon(
                  Icons.drag_indicator,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              Checkbox(
                value: taskCompleted,
                onChanged: onChanged,
                activeColor: Theme.of(context).colorScheme.surface,
                checkColor: Theme.of(context).colorScheme.onPrimary,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                splashRadius: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taskName,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        decoration: taskCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (taskDateTime != null)
                      Text(
                        DateFormat('MMM d, y HH:mm').format(taskDateTime!),
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
