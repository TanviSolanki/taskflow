import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../utils/task_utils.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final task = provider.taskById(taskId);

        if (task == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Task Detail')),
            body: const Center(child: Text('Task not found in the current list.')),
          );
        }

        final priority = colorForPriority(task.priority);
        final overdue = isTaskOverdue(task);
        final dueLabel = task.dueDate == null
            ? 'No due date'
            : DateFormat.yMMMEd().format(DateTime.parse(task.dueDate!));

        return Scaffold(
          appBar: AppBar(title: const Text('Task Detail')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                task.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: task.completed ? TextDecoration.lineThrough : null,
                    ),
              ),
              const SizedBox(height: 16),
              _DetailRow(
                icon: Icons.description_outlined,
                label: 'Description',
                value: task.description.isEmpty ? '—' : task.description,
              ),
              _DetailRow(
                icon: Icons.calendar_today,
                label: 'Due date',
                value: dueLabel,
                valueColor: overdue ? Colors.red.shade700 : null,
                trailing: overdue
                    ? Chip(
                        label: const Text('Overdue'),
                        backgroundColor: Colors.red.shade50,
                        side: BorderSide(color: Colors.red.shade200),
                        labelStyle: TextStyle(color: Colors.red.shade700),
                      )
                    : null,
              ),
              _DetailRow(
                icon: Icons.flag_outlined,
                label: 'Priority',
                value: priority.label,
                valueColor: Color(priority.colorValue),
              ),
              _DetailRow(
                icon: Icons.person_outline,
                label: 'Assignee',
                value: formatAssigneeLabel(task.assigneeId),
              ),
              _DetailRow(
                icon: Icons.check_circle_outline,
                label: 'Status',
                value: task.completed ? 'Completed' : 'Active',
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () async {
                  final error = await provider.toggleTaskOptimistic(task.id);
                  if (error != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error)),
                    );
                  }
                },
                icon: Icon(task.completed ? Icons.restart_alt : Icons.check),
                label: Text(task.completed ? 'Mark as Incomplete' : 'Mark as Complete'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}