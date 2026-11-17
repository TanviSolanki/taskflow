import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/task_api_service.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider({TaskApiService? api}) : _api = api ?? TaskApiService();

  final TaskApiService _api;

  List<Task> _tasks = [];
  final Map<String, Task> _taskCache = {};
  bool _loading = false;
  String? _error;
  String _assigneeFilter = 'all';
  String _statusFilter = 'all';

  List<Task> get tasks => _tasks;
  bool get loading => _loading;
  String? get error => _error;
  String get assigneeFilter => _assigneeFilter;
  String get statusFilter => _statusFilter;

  Future<void> loadTasks() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _api.fetchTasks(
        assignee: _assigneeFilter,
        status: _statusFilter,
      );
      for (final task in _tasks) {
        _taskCache[task.id] = task;
      }
    } on TaskApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Unable to connect to the server. Is the backend running?';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setAssigneeFilter(String value) {
    if (_assigneeFilter == value) return;
    _assigneeFilter = value;
    loadTasks();
  }

  void setStatusFilter(String value) {
    if (_statusFilter == value) return;
    _statusFilter = value;
    loadTasks();
  }

  Task? taskById(String id) {
    final fromList = _tasks.where((task) => task.id == id);
    if (fromList.isNotEmpty) return fromList.first;
    return _taskCache[id];
  }

  Future<String?> toggleTaskOptimistic(String id) async {
    final previous = taskById(id);
    if (previous == null) return 'Task not found.';

    final optimistic = previous.copyWith(completed: !previous.completed);
    _applyTaskUpdate(optimistic);
    notifyListeners();

    try {
      final updated = await _api.toggleTask(id);
      _applyTaskUpdate(updated);
      notifyListeners();
      return null;
    } catch (e) {
      _applyTaskUpdate(previous);
      notifyListeners();
      return e is TaskApiException ? e.message : 'Failed to update task.';
    }
  }

  void _applyTaskUpdate(Task task) {
    _taskCache[task.id] = task;

    final index = _tasks.indexWhere((item) => item.id == task.id);
    final matchesFilter = _matchesCurrentFilters(task);

    if (matchesFilter) {
      if (index != -1) {
        _tasks[index] = task;
      } else {
        _tasks = [..._tasks, task];
      }
    } else if (index != -1) {
      _tasks = _tasks.where((item) => item.id != task.id).toList();
    }
  }

  Future<TaskApiException?> createTask(Task task) async {
    try {
      final created = await _api.createTask(task);
      if (_matchesCurrentFilters(created)) {
        _taskCache[created.id] = created;
        _tasks = [..._tasks, created];
        notifyListeners();
      } else {
        await loadTasks();
      }
      return null;
    } on TaskApiException catch (e) {
      return e;
    } catch (_) {
      return TaskApiException('Unable to create task. Check your connection.');
    }
  }

  bool _matchesCurrentFilters(Task task) {
    if (_assigneeFilter != 'all' && task.assigneeId != _assigneeFilter) {
      return false;
    }
    if (_statusFilter == 'active' && task.completed) return false;
    if (_statusFilter == 'completed' && !task.completed) return false;
    return true;
  }
}