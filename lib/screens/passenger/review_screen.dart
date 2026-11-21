import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/ui_helpers.dart';
import '../../state/app_state.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/rating_widgets.dart';
import '../../widgets/responsive_body.dart';

/// Rate a driver and leave a comment after a completed trip.
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, required this.requestId});

  final String requestId;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 0;
  bool _showRatingError = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    final valid = _formKey.currentState!.validate();
    setState(() => _showRatingError = _rating == 0);
    if (!valid || _rating == 0) return;
    final state = AppState.instance;
    final request = state.requestById(widget.requestId);
    if (request == null) return;
    final review = state.addReview(request, _rating, _commentController.text);
    if (review == null) {
      showMessage(context, 'This trip cannot be reviewed.', error: true);
      return;
    }
    showMessage(context, 'Thank you for your review.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final request = state.requestById(widget.requestId);
    final driver = request?.driver == null ? null : state.findUser(request!.driver!);
    if (request == null || driver == null) {
      return Scaffold(
        appBar: const AppTopBar(title: 'Rate your driver'),
        body: const EmptyState(
          icon: Icons.rate_review_outlined,
          title: 'Nothing to review',
          message: 'You can review a driver after a completed trip.',
        ),
      );
    }
    const labels = ['Tap a star', 'Poor', 'Fair', 'Good', 'Very good', 'Excellent'];
    return Scaffold(
      appBar: const AppTopBar(title: 'Rate your driver'),
      body: SafeArea(
        child: ResponsiveBody(
          maxWidth: 520,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.green,
                        child: Text(driver.initials, style: const TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(driver.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                            Text('${request.pickup} to ${request.destination}',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SectionTitle('How was your trip?'),
                AppCard(
                  child: Column(
                    children: [
                      StarSelector(rating: _rating, onChanged: (v) => setState(() => _rating = v)),
                      Text(labels[_rating], style: const TextStyle(fontWeight: FontWeight.w700)),
                      if (_showRatingError && _rating == 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('Please choose a rating', style: TextStyle(color: AppColors.red)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _commentController,
                  label: 'Comment (optional)',
                  icon: Icons.rate_review_outlined,
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                  validator: (v) => (v ?? '').length > 300 ? 'Please use 300 characters or fewer' : null,
                ),
                const SizedBox(height: 8),
                const NoteBox(
                  text: 'Your first name and comment are shown on the driver\'s profile. Be honest and polite.',
                ),
                const SizedBox(height: 20),
                PrimaryButton(label: 'Send review', icon: Icons.send, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
