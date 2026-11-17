import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/task.dart';

class TaskApiException implements Exception {
  TaskApiException(this.message, {this.fieldErrors});

  final String message;
  final Map<String, String>? fieldErrors;
}

class TaskApiService {
  TaskApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final String _baseUrl = ApiConfig.baseUrl;

  Future<List<Task>> fetchTasks({
    String? assignee,
    String? status,
  }) async {
    final query = <String, String>{};
    if (assignee != null && assignee != 'all') {
      query['assignee'] = assignee;
    }
    if (status != null && status != 'all') {
      query['status'] = status;
    }

    final uri = Uri.parse('$_baseUrl/api/tasks').replace(queryParameters: query);
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw TaskApiException('Failed to load tasks (${response.statusCode}).');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final tasks = data['tasks'] as List<dynamic>;
    return tasks.map((item) => Task.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Task> createTask(Task task) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toCreateJson()),
    );

    if (response.statusCode == 400) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final errors = (data['errors'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value.toString()));
      throw TaskApiException(
        data['message']?.toString() ?? 'Validation failed.',
        fieldErrors: errors,
      );
    }

    if (response.statusCode != 201) {
      throw TaskApiException('Failed to create task (${response.statusCode}).');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Task.fromJson(data['task'] as Map<String, dynamic>);
  }

  Future<Task> toggleTask(String id) async {
    final response = await _client.patch(
      Uri.parse('$_baseUrl/api/tasks/$id/toggle'),
    );

    if (response.statusCode == 404) {
      throw TaskApiException('Task not found.');
    }

    if (response.statusCode != 200) {
      throw TaskApiException('Failed to toggle task (${response.statusCode}).');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Task.fromJson(data['task'] as Map<String, dynamic>);
  }
}