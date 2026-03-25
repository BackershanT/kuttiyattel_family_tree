import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Date picker widget for birth date selection
class DatePickerWidget extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String? errorText;

  const DatePickerWidget({
    super.key,
    this.label = 'Date of Birth',
    this.value,
    required this.onChanged,
    this.errorText,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime(1950),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select $label',
      cancelText: 'Cancel',
      confirmText: 'OK',
    );

    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: errorText != null ? Colors.red : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
              color: errorText != null
                  ? Colors.red.shade50
                  : Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: errorText != null ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    value != null
                        ? DateFormat('MMMM dd, yyyy').format(value!)
                        : 'Select date',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: value != null
                              ? null
                              : Colors.grey.shade600,
                        ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
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
