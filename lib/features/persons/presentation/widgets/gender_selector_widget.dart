import 'package:flutter/material.dart';

/// Segmented button for gender selection (Male/Female/Other)
class GenderSelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? errorText;

  const GenderSelector({
    super.key,
    this.value,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender *',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'Male',
              label: Text('Male'),
              icon: Icon(Icons.male),
            ),
            ButtonSegment(
              value: 'Female',
              label: Text('Female'),
              icon: Icon(Icons.female),
            ),
            ButtonSegment(
              value: 'Other',
              label: Text('Other'),
              icon: Icon(Icons.person_outline),
            ),
          ],
          selected: {value ?? 'Other'},
          onSelectionChanged: (Set<String> newSelection) {
            onChanged(newSelection.first);
          },
          emptySelectionAllowed: false,
          showSelectedIcon: true,
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                ),
          ),
        ],
      ],
    );
  }
}
