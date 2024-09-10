import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TodoList extends StatelessWidget {
  const TodoList({
    super.key,
    required this.taskId,
    required this.taskName,
    required this.taskCompleted,
    required this.backgroundColor,
    required this.onChanged,
    required this.deleteFunction,
      required this.position,
  });

  final int taskId;
  final String taskName;
  final bool taskCompleted;
  final Color backgroundColor;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteFunction;
    final int position;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0), // Padding autour de l'élément
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
               onPressed: deleteFunction,
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              autoClose: true,
              borderRadius: BorderRadius.circular(15), // Coins arrondis pour le bouton de suppression
              padding: EdgeInsets.all(15),
              spacing: 10,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15), // Coins arrondis
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0), // Padding interne
            title: Text(
              (position+1).toString() +'- $taskName', // Afficher la position avant le nom
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                decoration: taskCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: Colors.white,
                decorationThickness: 2,
              ),
            ),
            trailing: Checkbox(
              value: taskCompleted,
              onChanged: onChanged,
              checkColor: Colors.black,
              activeColor: Colors.white,
              side: const BorderSide(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
