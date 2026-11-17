import '../models/task.dart';

String todayDateString() {
  final now = DateTime.now();
  return _formatDate(DateTime(now.year, now.month, now.day));
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

bool isTaskOverdue(Task task) {
  if (task.dueDate == null || task.dueDate!.isEmpty) {
    return false;
  }
  if (task.completed) {
    return false;
  }

  try {
    final parts = task.dueDate!.split('-');
    final due = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    return due.isBefore(todayOnly);
  } catch (_) {
    return false;
  }
}

String formatAssigneeLabel(String assigneeId) {
  if (assigneeId.isEmpty) return assigneeId;
  return assigneeId[0].toUpperCase() + assigneeId.substring(1);
}

ColorPriority colorForPriority(String priority) {
  switch (priority) {
    case 'high':
      return ColorPriority(colorValue: 0xFFE53935, label: 'High');
    case 'medium':
      return ColorPriority(colorValue: 0xFFFB8C00, label: 'Medium');
    default:
      return ColorPriority(colorValue: 0xFF43A047, label: 'Low');
  }
}

class ColorPriority {
  const ColorPriority({required this.colorValue, required this.label});

  final int colorValue;
  final String label;
}