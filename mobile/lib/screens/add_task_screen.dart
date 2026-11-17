import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/priority_chip_selector.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _priority = 'medium';
  String _assigneeId = 'aarav';
  DateTime? _dueDate;
  bool _submitting = false;
  Map<String, String> _serverErrors = {};

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  String? _titleValidator(String? value) {
    if (_serverErrors.containsKey('title')) {
      return _serverErrors['title'];
    }
    if (value == null || value.trim().isEmpty) {
      return 'Title is required.';
    }
    return null;
  }

  Future<void> _submit() async {
    setState(() {
      _serverErrors = {};
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);

    final task = Task(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _dueDate == null ? null : _formatDate(_dueDate!),
      priority: _priority,
      assigneeId: _assigneeId,
      completed: false,
    );

    final error = await context.read<TaskProvider>().createTask(task);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (error == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully.')),
      );
      return;
    }

    setState(() {
      _serverErrors = error.fieldErrors ?? {};
    });

    _formKey.currentState!.validate();

    if (_serverErrors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: _titleValidator,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Due date (optional)',
                border: const OutlineInputBorder(),
                errorText: _serverErrors['dueDate'],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _dueDate == null
                          ? 'No date selected'
                          : _formatDate(_dueDate!),
                    ),
                  ),
                  TextButton(onPressed: _pickDueDate, child: const Text('Pick')),
                  if (_dueDate != null)
                    IconButton(
                      onPressed: () => setState(() => _dueDate = null),
                      icon: const Icon(Icons.clear),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PriorityChipSelector(
              selected: _priority,
              onChanged: (value) => setState(() => _priority = value),
              errorText: _serverErrors['priority'],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _assigneeId,
              decoration: InputDecoration(
                labelText: 'Assignee',
                border: const OutlineInputBorder(),
                errorText: _serverErrors['assigneeId'],
              ),
              items: const [
                DropdownMenuItem(value: 'aarav', child: Text('Aarav')),
                DropdownMenuItem(value: 'priya', child: Text('Priya')),
                DropdownMenuItem(value: 'rohan', child: Text('Rohan')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _assigneeId = value);
                }
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }
}