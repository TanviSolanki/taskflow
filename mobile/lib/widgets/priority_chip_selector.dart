import 'package:flutter/material.dart';

class PriorityChipSelector extends StatelessWidget {
  const PriorityChipSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.errorText,
  });

  final String selected;
  final ValueChanged<String> onChanged;
  final String? errorText;

  static const _options = [
    ('low', 'Low'),
    ('medium', 'Medium'),
    ('high', 'High'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: _options
              .map((option) => ButtonSegment(value: option.$1, label: Text(option.$2)))
              .toList(),
          selected: {selected},
          onSelectionChanged: (values) => onChanged(values.first),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
          ),
        ],
      ],
    );
  }
}