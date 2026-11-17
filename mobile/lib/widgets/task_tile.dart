import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../utils/task_utils.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
  });

  final Task task;
  final VoidCallback onTap;
  final ValueChanged<bool?> onToggle;

  @override
  Widget build(BuildContext context) {
    final overdue = isTaskOverdue(task);
    final priority = colorForPriority(task.priority);
    final dueLabel = task.dueDate == null
        ? 'No due date'
        : DateFormat.yMMMd().format(DateTime.parse(task.dueDate!));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: task.completed,
          onChanged: onToggle,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: overdue ? Colors.red.shade700 : Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  dueLabel,
                  style: TextStyle(
                    color: overdue ? Colors.red.shade700 : null,
                    fontWeight: overdue ? FontWeight.w600 : null,
                  ),
                ),
                if (overdue) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      'Overdue',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Color(priority.colorValue).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            priority.label,
            style: TextStyle(
              color: Color(priority.colorValue),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}