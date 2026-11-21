import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../models/models.dart';
import 'common_widgets.dart';

/// Progress of a request: Requested, Driver accepted, Confirmed, Completed.
class TripStepper extends StatelessWidget {
  const TripStepper({super.key, required this.status});

  final RequestStatus status;

  static const List<String> _labels = ['Requested', 'Driver accepted', 'Confirmed', 'Completed'];

  int get _current {
    switch (status) {
      case RequestStatus.pending:
        return 0;
      case RequestStatus.awaitingPassenger:
        return 1;
      case RequestStatus.confirmed:
        return 2;
      case RequestStatus.completed:
        return 3;
      case RequestStatus.cancelled:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _current;
    if (current < 0) {
      return NoteBox(
        text: 'This request was cancelled.',
        icon: Icons.cancel_outlined,
        color: AppColors.red,
        background: AppColors.redTint,
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _labels.length; i++)
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _line(i > 0 && i <= current)),
                    _dot(i, current),
                    Expanded(child: _line(i < _labels.length - 1 && i < current)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: i == current ? FontWeight.w800 : FontWeight.w500,
                    color: i <= current ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _line(bool filled) {
    return Container(height: 3, color: filled ? AppColors.green : AppColors.border);
  }

  Widget _dot(int index, int current) {
    final done = index < current;
    final active = index == current;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.green : AppColors.surface,
        border: Border.all(
          color: (done || active) ? AppColors.green : AppColors.border,
          width: active ? 3 : 2,
        ),
      ),
      child: done ? const Icon(Icons.check, size: 15, color: Colors.white) : null,
    );
  }
}
