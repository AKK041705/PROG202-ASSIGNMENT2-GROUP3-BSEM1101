import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/fare_tile.dart';
import '../../widgets/rating_widgets.dart';
import '../../widgets/responsive_body.dart';

/// A driver's public profile: rating, customer reviews and past trips.
class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key, required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final driver = state.findUser(username);
        if (driver == null || driver.role != UserRole.driver) {
          return Scaffold(
            appBar: const AppTopBar(title: 'Driver profile'),
            body: const EmptyState(
              icon: Icons.person_off_outlined,
              title: 'Driver not found',
              message: 'This driver is no longer available.',
            ),
          );
        }
        final viewer = state.currentUser;
        final average = state.averageRating(driver.username);
        final reviews = state.reviewsForDriver(driver.username);
        final trips = state.requests
            .where((r) => r.driver == driver.username && r.status == RequestStatus.completed)
            .toList()
            .reversed
            .toList();

        // The phone number is private until the driver has accepted this person's request.
        final canSeePhone = viewer != null &&
            (viewer.role == UserRole.administrator ||
                viewer.username == driver.username ||
                state.requests.any((r) =>
                    r.driver == driver.username &&
                    r.passenger == viewer.username &&
                    r.status != RequestStatus.cancelled));

        final counts = List<int>.filled(6, 0);
        for (final r in reviews) {
          counts[r.rating] = counts[r.rating] + 1;
        }

        return Scaffold(
          appBar: AppTopBar(title: driver.name),
          body: SafeArea(
            child: ResponsiveBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(18)),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.white,
                          child: Text(
                            driver.initials,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.greenDark),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driver.name,
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                '${driver.driverType ?? ''} driver',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(driver.verified ? Icons.verified : Icons.hourglass_top, color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    driver.verified ? 'Verified by the administrator' : 'Waiting for verification',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: MiniStat(
                          label: 'Rating',
                          value: average == null ? '-' : average.toStringAsFixed(1),
                          icon: Icons.star_outline,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: MiniStat(label: 'Reviews', value: '${reviews.length}', icon: Icons.rate_review_outlined)),
                      const SizedBox(width: 10),
                      Expanded(child: MiniStat(label: 'Trips done', value: '${trips.length}', icon: Icons.flag_circle_outlined)),
                    ],
                  ),
                  const SectionTitle('About this driver'),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoRow('Type', driver.driverType ?? '-'),
                        InfoRow('Vehicle', driver.vehicle ?? '-'),
                        InfoRow('Plate', driver.plate ?? '-'),
                        InfoRow('Phone', canSeePhone ? driver.phone : 'Shown after the driver accepts your request'),
                      ],
                    ),
                  ),
                  const SectionTitle('Ratings'),
                  AppCard(
                    child: reviews.isEmpty
                        ? Text('No ratings yet.', style: TextStyle(color: AppColors.textSecondary))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    average!.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RatingStars(rating: average, size: 20),
                                      Text('${reviews.length} review(s)',
                                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              for (var star = 5; star >= 1; star--)
                                BarRow(
                                  label: '$star star${star == 1 ? '' : 's'}',
                                  value: counts[star],
                                  total: reviews.length,
                                  color: AppColors.green,
                                ),
                            ],
                          ),
                  ),
                  const SectionTitle('Past trips'),
                  if (trips.isEmpty) const NoteBox(text: 'No completed trips yet.'),
                  for (final trip in trips.take(5))
                    AppCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Icon(modeIcon(trip.mode), color: AppColors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('${trip.pickup} to ${trip.destination}',
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          Text(trip.mode, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  const SectionTitle('Customer reviews'),
                  if (reviews.isEmpty)
                    const EmptyState(
                      icon: Icons.rate_review_outlined,
                      title: 'No reviews yet',
                      message: 'Reviews from passengers appear here after their trips.',
                    ),
                  for (final review in reviews) ReviewTile(review: review),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
