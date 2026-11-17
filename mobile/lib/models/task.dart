class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.assigneeId,
    required this.completed,
  });

  final String id;
  final String title;
  final String description;
  final String? dueDate;
  final String priority;
  final String assigneeId;
  final bool completed;

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      dueDate: json['dueDate'] as String?,
      priority: json['priority'] as String,
      assigneeId: json['assigneeId'] as String,
      completed: json['completed'] as bool? ?? false,
    );
  }

  Task copyWith({bool? completed}) {
    return Task(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      assigneeId: assigneeId,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'description': description,
      if (dueDate != null) 'dueDate': dueDate,
      'priority': priority,
      'assigneeId': assigneeId,
    };
  }
}