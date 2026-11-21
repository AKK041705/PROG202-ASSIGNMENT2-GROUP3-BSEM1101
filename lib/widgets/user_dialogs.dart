import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../models/models.dart';
import '../state/app_state.dart';

/// Asks for some text in a dialog. Returns the text, or null if cancelled.
Future<String?> askForText(
  BuildContext context, {
  required String title,
  required String label,
  required String confirmLabel,
  String? hint,
  int minLength = 3,
}) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => _AskForTextDialog(
      title: title,
      label: label,
      confirmLabel: confirmLabel,
      hint: hint,
      minLength: minLength,
    ),
  );
}

/// The dialog manages its own TextEditingController.
class _AskForTextDialog extends StatefulWidget {
  const _AskForTextDialog({
    required this.title,
    required this.label,
    required this.confirmLabel,
    this.hint,
    required this.minLength,
  });

  final String title;
  final String label;
  final String confirmLabel;
  final String? hint;
  final int minLength;

  @override
  State<_AskForTextDialog> createState() => _AskForTextDialogState();
}

class _AskForTextDialogState extends State<_AskForTextDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          maxLines: 3,
          autofocus: true,
          decoration: appInputDecoration(
            widget.label,
            Icons.edit_note,
            hint: widget.hint,
          ),
          validator: (value) {
            if (value == null || value.trim().length < widget.minLength) {
              return 'Please write at least ${widget.minLength} characters';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            Navigator.pop(context, _controller.text.trim());
          },
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

/// The administrator sends a message. The other person gets a notification.
Future<void> messageUserDialog(BuildContext context, AppUser target) async {
  final admin = AppState.instance.currentUser;
  if (admin == null) return;

  final text = await askForText(
    context,
    title: 'Message ${target.name}',
    label: 'Your message',
    confirmLabel: 'Send',
  );

  if (text == null || !context.mounted) return;

  AppState.instance.sendMessage(admin, target.username, text);
  showMessage(context, 'Message sent. ${target.name} has been notified.');
}

/// The administrator suspends or reinstates an account.
Future<void> toggleSuspendDialog(BuildContext context, AppUser target) async {
  final state = AppState.instance;

  if (target.suspended) {
    final ok = await confirmAction(
      context,
      title: 'Reinstate ${target.name}?',
      message: 'They will be able to log in again.',
      confirmLabel: 'Reinstate',
    );

    if (!ok || !context.mounted) return;

    state.reinstateUser(target);
    showMessage(context, '${target.name} was reinstated.');
    return;
  }

  final reason = await askForText(
    context,
    title: 'Suspend ${target.name}?',
    label: 'Reason (they will see it)',
    confirmLabel: 'Suspend',
  );

  if (reason == null || !context.mounted) return;

  state.suspendUser(target, reason);
  showMessage(context, '${target.name} was suspended and notified.');
}

/// A driver or passenger reports a problem with the other person on a trip.
Future<void> reportUserDialog(
  BuildContext context,
  TransportRequest request,
  AppUser subject,
) async {
  final reporter = AppState.instance.currentUser;
  if (reporter == null) return;

  final text = await askForText(
    context,
    title: 'Report ${subject.name}',
    label: 'What happened?',
    confirmLabel: 'Send report',
    hint: 'The administrator will review this.',
    minLength: 10,
  );

  if (text == null || !context.mounted) return;

  AppState.instance.reportUser(
    reporter: reporter,
    subject: subject.username,
    requestId: request.id,
    text: text,
  );

  showMessage(context, 'Report sent to the administrator.');
}
