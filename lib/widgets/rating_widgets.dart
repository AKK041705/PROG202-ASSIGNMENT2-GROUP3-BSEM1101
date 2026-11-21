import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/date_format.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'app_card.dart';

const Color _starColor = Color(0xFFE5A400);

/// Shows a rating such as 4.5 out of 5 as stars.
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 18});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            rating >= i ? Icons.star : (rating >= i - 0.5 ? Icons.star_half : Icons.star_border),
            size: size,
            color: _starColor,
          ),
      ],
    );
  }
}

/// Five stars the user taps to choose a rating from 1 to 5.
class StarSelector extends StatelessWidget {
  const StarSelector({super.key, required this.rating, required this.onChanged});

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            tooltip: '$i star${i == 1 ? '' : 's'}',
            iconSize: 42,
            onPressed: () => onChanged(i),
            icon: Icon(i <= rating ? Icons.star : Icons.star_border, color: _starColor),
          ),
      ],
    );
  }
}

/// One customer review: who wrote it, the stars and the comment.
class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key, required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final author = AppState.instance.findUser(review.passenger);
    final firstName = author == null ? 'Passenger' : author.name.split(' ').first;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.green,
                child: Text(
                  firstName.isEmpty ? '?' : firstName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(firstName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(DateText.day(review.time), style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              RatingStars(rating: review.rating.toDouble(), size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment.isEmpty ? 'No comment.' : review.comment,
            style: TextStyle(
              height: 1.35,
              fontStyle: review.comment.isEmpty ? FontStyle.italic : FontStyle.normal,
              color: review.comment.isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
