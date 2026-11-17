import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

const _validPriorities = {'low', 'medium', 'high'};
const _validAssignees = {'aarav', 'priya', 'rohan'};
const _uuid = Uuid();

final _seedTasks = [
  {
    'title': 'Complete project proposal',
    'description': 'Draft and send the proposal to the client.',
    'dueDate': '2026-10-15',
    'priority': 'high',
    'assigneeId': 'aarav',
    'completed': false,
  },
  {
    'title': 'Review design mockups',
    'description': 'Provide feedback on new UI designs.',
    'dueDate': '2026-10-12',
    'priority': 'medium',
    'assigneeId': 'aarav',
    'completed': true,
  },
  {
    'title': 'Team standup meeting',
    'description': 'Daily sync with the development team.',
    'dueDate': '2026-10-10',
    'priority': 'low',
    'assigneeId': 'aarav',
    'completed': false,
  },
  {
    'title': 'Update portfolio website',
    'description': 'Add recent projects and update the about section.',
    'dueDate': null,
    'priority': 'medium',
    'assigneeId': 'aarav',
    'completed': false,
  },
  {
    'title': 'Prepare client presentation',
    'description': 'Create slides for the quarterly business review.',
    'dueDate': '2026-10-18',
    'priority': 'high',
    'assigneeId': 'priya',
    'completed': false,
  },
  {
    'title': 'Fix login bug',
    'description': 'Resolve Google OAuth login issue.',
    'dueDate': '2026-10-11',
    'priority': 'high',
    'assigneeId': 'priya',
    'completed': true,
  },
  {
    'title': 'Write blog post',
    'description': 'Draft an article on mobile apps for business.',
    'dueDate': '2026-10-25',
    'priority': 'low',
    'assigneeId': 'priya',
    'completed': false,
  },
  {
    'title': 'Test payment gateway',
    'description': 'Run end-to-end Stripe tests on staging.',
    'dueDate': '2026-10-14',
    'priority': 'medium',
    'assigneeId': 'priya',
    'completed': false,
  },
  {
    'title': 'Update documentation',
    'description': 'Add API endpoint details to README.',
    'dueDate': '2026-10-22',
    'priority': 'low',
    'assigneeId': 'priya',
    'completed': false,
  },
  {
    'title': 'Design new landing page',
    'description': 'High-fidelity mockup for product launch.',
    'dueDate': '2026-10-16',
    'priority': 'high',
    'assigneeId': 'rohan',
    'completed': false,
  },
  {
    'title': 'Conduct user interviews',
    'description': 'Schedule 5 user interviews for beta feedback.',
    'dueDate': '2026-10-19',
    'priority': 'medium',
    'assigneeId': 'rohan',
    'completed': false,
  },
  {
    'title': 'Optimise database queries',
    'description': 'Improve query performance for task list.',
    'dueDate': '2026-10-13',
    'priority': 'high',
    'assigneeId': 'rohan',
    'completed': true,
  },
  {
    'title': 'Set up CI/CD pipeline',
    'description': 'Configure GitHub Actions for testing and deployment.',
    'dueDate': '2026-10-21',
    'priority': 'medium',
    'assigneeId': 'rohan',
    'completed': false,
  },
  {
    'title': 'Review pull requests',
    'description': 'Review and merge pending PRs.',
    'dueDate': '2026-10-10',
    'priority': 'low',
    'assigneeId': 'rohan',
    'completed': true,
  },
  {
    'title': 'Plan sprint retrospective',
    'description': 'Organise the sprint retrospective meeting.',
    'dueDate': '2026-10-23',
    'priority': 'low',
    'assigneeId': 'rohan',
    'completed': false,
  },
];

final List<Map<String, dynamic>> _tasks = _seedTasks
    .map((task) => {...task, 'id': _uuid.v4()})
    .toList();

Response _json(Object body, {int statusCode = HttpStatus.ok}) {
  return Response(
    statusCode,
    body: jsonEncode(body),
    headers: {'Content-Type': 'application/json; charset=utf-8'},
  );
}

Map<String, String> _validateBody(Map<String, dynamic> body) {
  final errors = <String, String>{};

  final title = body['title'];
  if (title == null) {
    errors['title'] = 'Title is required.';
  } else if (title is! String || title.trim().isEmpty) {
    errors['title'] = 'Title must be a non-empty string.';
  }

  final priority = body['priority'];
  if (priority == null) {
    errors['priority'] = 'Priority is required.';
  } else if (priority is! String || !_validPriorities.contains(priority)) {
    errors['priority'] = 'Priority must be one of: low, medium, high.';
  }

  final assigneeId = body['assigneeId'];
  if (assigneeId == null) {
    errors['assigneeId'] = 'Assignee is required.';
  } else if (assigneeId is! String || !_validAssignees.contains(assigneeId)) {
    errors['assigneeId'] = 'Assignee must be one of: aarav, priya, rohan.';
  }

  final dueDate = body['dueDate'];
  if (dueDate != null && dueDate is String && dueDate.isNotEmpty) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dueDate)) {
      errors['dueDate'] = 'Due date must be in YYYY-MM-DD format.';
    }
  }

  return errors;
}

void main() async {
  final router = Router();

  router.get('/api/tasks', (Request request) {
    final assignee = request.url.queryParameters['assignee'];
    final status = request.url.queryParameters['status'];

    var filtered = List<Map<String, dynamic>>.from(_tasks);

    if (assignee != null && assignee.isNotEmpty && assignee != 'all') {
      filtered = filtered.where((t) => t['assigneeId'] == assignee).toList();
    }

    if (status == 'active') {
      filtered = filtered.where((t) => t['completed'] != true).toList();
    } else if (status == 'completed') {
      filtered = filtered.where((t) => t['completed'] == true).toList();
    }

    return _json({'tasks': filtered});
  });

  router.post('/api/tasks', (Request request) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final errors = _validateBody(body);

    if (errors.isNotEmpty) {
      return _json(
        {'errors': errors, 'message': 'Validation failed.'},
        statusCode: HttpStatus.badRequest,
      );
    }

    final task = {
      'id': _uuid.v4(),
      'title': (body['title'] as String).trim(),
      'description': (body['description'] as String?)?.trim() ?? '',
      'dueDate': body['dueDate'],
      'priority': body['priority'],
      'assigneeId': body['assigneeId'],
      'completed': false,
    };

    _tasks.add(task);
    return _json({'task': task}, statusCode: HttpStatus.created);
  });

  router.patch('/api/tasks/<id>/toggle', (Request request, String id) {
    final index = _tasks.indexWhere((task) => task['id'] == id);
    if (index == -1) {
      return _json({'message': 'Task not found.'}, statusCode: HttpStatus.notFound);
    }

    final task = _tasks[index];
    task['completed'] = !(task['completed'] as bool);
    return _json({'task': task});
  });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router.call);

  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 3000;
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  stdout.writeln('TaskFlow API running at http://localhost:${server.port}');
}