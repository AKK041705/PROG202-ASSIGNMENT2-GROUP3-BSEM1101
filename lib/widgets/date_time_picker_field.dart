import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/date_format.dart';
import '../core/ui_helpers.dart';

/// A form field that opens the date picker and then the time picker.
class DateTimePickerField extends StatefulWidget {
  const DateTimePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  @override
  State<DateTimePickerField> createState() => _DateTimePickerFieldState();
}

class _DateTimePickerFieldState extends State<DateTimePickerField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value == null ? '' : DateText.full(widget.value!));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final start = widget.value ?? now.add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: start.isBefore(now) ? now : start,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 60)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: start.hour, minute: start.minute),
    );
    if (time == null || !mounted) return;
    final picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    _controller.text = DateText.full(picked);
    widget.onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      showCursor: false,
      onTap: _pick,
      validator: (text) {
        final chosen = widget.value;
        if (chosen == null) return 'Choose a date and time';
        if (chosen.isBefore(DateTime.now().add(const Duration(minutes: 5)))) {
          return 'Choose a time in the future';
        }
        return null;
      },
      style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
      decoration: appInputDecoration(widget.label, Icons.event_outlined, hint: 'Tap to choose').copyWith(
        suffixIcon: Icon(Icons.edit_calendar_outlined, color: AppColors.textSecondary),
      ),
    );
  }
}
