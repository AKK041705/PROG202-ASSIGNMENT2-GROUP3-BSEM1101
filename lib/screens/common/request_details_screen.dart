import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../core/date_format.dart';
import '../../core/ui_helpers.dart';
import '../../data/fare_service.dart';
import '../../models/models.dart';
import '../../services/currency_service.dart';
import '../../state/app_state.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/fare_tile.dart';
import '../../widgets/rating_widgets.dart';
import '../../widgets/responsive_body.dart';
import '../../widgets/searching_radar.dart';
import '../../widgets/user_dialogs.dart';
import '../../widgets/trip_stepper.dart';
import '../../widgets/status_chip.dart';

/// Shows one request. The buttons at the bottom depend on who is looking:
/// the passenger can accept or reject the driver, the driver can accept,
/// decline or complete, and the administrator can only view.
class RequestDetailsScreen extends StatelessWidget {
  const RequestDetailsScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final request = state.requestById(requestId);
        final user = state.currentUser;
        if (request == null || user == null) {
          return Scaffold(
            appBar: const AppTopBar(title: 'Request'),
            body: const EmptyState(
              icon: Icons.search_off,
              title: 'Request not found',
              message: 'This request is no longer available.',
            ),
          );
        }
        final passenger = state.findUser(request.passenger);
        final driver = request.driver == null ? null : state.findUser(request.driver!);

        return Scaffold(
          appBar: AppTopBar(title: request.id),
          body: SafeArea(
            child: ResponsiveBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (request.status == RequestStatus.pending) ...[
                    AppCard(
                      child: Column(
                        children: [
                          SearchingRadar(mode: request.mode),
                          Text(
                            'Searching for a verified ${FareService.driverTypeFor(request.mode)} driver...',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You will get a notification when a driver accepts.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  AppCard(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16), child: TripStepper(status: request.status)),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(color: AppColors.greenTint, shape: BoxShape.circle),
                              child: Icon(modeIcon(request.mode), color: AppColors.green),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${request.pickup} to ${request.destination}',
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        StatusChip.request(request.status),
                        const SizedBox(height: 12),
                        InfoRow('Transport', request.mode),
                        InfoRow('People', '${request.people}'),
                        InfoRow('Extra seats free', '${request.freeSeats}'),
                        InfoRow('Estimated fare', request.fareText),
                        InfoRow('Payment', CurrencyService.paymentText(request.payCurrency, request.payAmount)),
                        if (request.payAmount != null)
                          InfoRow('Payment status', request.paid ? 'Paid by ${request.payMethod} (demo)' : 'Not paid yet'),
                        InfoRow(
                          'Pickup time',
                          request.isScheduled ? DateText.when(request.scheduledAt!) : 'As soon as possible',
                        ),
                        if (request.note.isNotEmpty) InfoRow('Note', request.note),
                      ],
                    ),
                  ),
                  if (user.role == UserRole.driver || user.role == UserRole.administrator) ...[
                    const SectionTitle('Passenger'),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InfoRow('Name', passenger?.name ?? request.passenger),
                          InfoRow('Phone', passenger?.phone ?? '-'),
                        ],
                      ),
                    ),
                  ],
                  if (driver != null && user.role != UserRole.driver) ...[
                    const SectionTitle('Driver'),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InfoRow('Name', driver.name),
                          InfoRow('Phone', driver.phone),
                          InfoRow('Vehicle', driver.vehicle ?? '-'),
                          InfoRow('Plate', driver.plate ?? '-'),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.driverProfile,
                                arguments: driver.username,
                              ),
                              icon: const Icon(Icons.person_search_outlined),
                              label: const Text('View driver profile and reviews'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ..._actions(context, state, request, user),
                  ..._extras(context, request, user),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _actions(BuildContext context, AppState state, TransportRequest request, AppUser user) {
    final status = request.status;

    if (user.role == UserRole.passenger && request.passenger == user.username) {
      if (status == RequestStatus.awaitingPassenger) {
        return [
          const NoteBox(text: 'A driver accepted your request. Do you accept this driver?'),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Accept this driver',
            icon: Icons.check_circle_outline,
            onPressed: () {
              state.passengerAcceptDriver(request);
              showMessage(context, 'Driver accepted. Trip confirmed.');
            },
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Reject this driver',
            icon: Icons.person_off_outlined,
            color: AppColors.red,
            onPressed: () async {
              final ok = await confirmAction(
                context,
                title: 'Reject this driver?',
                message: 'Your request will go back to Pending so another driver can accept it.',
                confirmLabel: 'Reject',
              );
              if (!ok || !context.mounted) return;
              state.passengerRejectDriver(request);
              showMessage(context, 'Driver rejected. Your request is Pending again.');
            },
          ),
          const SizedBox(height: 10),
          _cancelButton(context, state, request),
        ];
      }
      if (status == RequestStatus.pending || status == RequestStatus.confirmed) {
        return [
          if (status == RequestStatus.pending)
            const NoteBox(text: 'Waiting for a verified driver to accept your request.'),
          if (status == RequestStatus.pending) const SizedBox(height: 12),
          _cancelButton(context, state, request),
        ];
      }
    }

    if (user.role == UserRole.driver) {
      if (status == RequestStatus.pending && !request.declinedDrivers.contains(user.username)) {
        return [
          PrimaryButton(
            label: 'Accept this request',
            icon: Icons.check_circle_outline,
            onPressed: () {
              state.driverAccept(request, user);
              showMessage(context, 'You accepted ${request.id}. Waiting for the passenger.');
            },
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Decline this request',
            icon: Icons.close,
            color: AppColors.red,
            onPressed: () {
              state.driverDecline(request, user);
              showMessage(context, 'You declined ${request.id}.');
              Navigator.pop(context);
            },
          ),
        ];
      }
      if (status == RequestStatus.awaitingPassenger && request.driver == user.username) {
        return [const NoteBox(text: 'You accepted this request. Waiting for the passenger to accept you.')];
      }
      if (status == RequestStatus.confirmed && request.driver == user.username) {
        return [
          PrimaryButton(
            label: 'Mark trip as completed',
            icon: Icons.flag_circle_outlined,
            onPressed: () {
              state.completeTrip(request);
              showMessage(context, 'Trip ${request.id} marked as completed.');
            },
          ),
        ];
      }
    }
    return [];
  }

  /// Track on the map, and the payment buttons for the passenger.
  List<Widget> _extras(BuildContext context, TransportRequest request, AppUser user) {
    final items = <Widget>[];
    final hasDriver = request.driver != null &&
        (request.status == RequestStatus.awaitingPassenger ||
            request.status == RequestStatus.confirmed ||
            request.status == RequestStatus.completed);
    if (hasDriver) {
      items.add(const SizedBox(height: 10));
      items.add(SecondaryButton(
        label: 'Track on map',
        icon: Icons.map_outlined,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.tripMap, arguments: request.id),
      ));
    }
    final isPassenger = user.role == UserRole.passenger && request.passenger == user.username;
    final canPay = request.status == RequestStatus.confirmed || request.status == RequestStatus.completed;
    if (isPassenger && canPay && request.payAmount != null) {
      items.add(const SizedBox(height: 10));
      if (request.paid) {
        items.add(SecondaryButton(
          label: 'View receipt',
          icon: Icons.receipt_long_outlined,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.receipt, arguments: request.id),
        ));
      } else {
        items.add(PrimaryButton(
          label: 'Pay now',
          icon: Icons.payments_outlined,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.payment, arguments: request.id),
        ));
      }
    }
    final isDriverOfTrip = user.role == UserRole.driver && request.driver == user.username;
    final tripActive = request.status == RequestStatus.awaitingPassenger || request.status == RequestStatus.confirmed;
    if (isDriverOfTrip && tripActive) {
      items.add(const SizedBox(height: 10));
      items.add(SecondaryButton(
        label: 'Cancel this trip',
        icon: Icons.cancel_outlined,
        color: AppColors.red,
        onPressed: () async {
          final ok = await confirmAction(
            context,
            title: 'Cancel this trip?',
            message: 'The passenger will be told, and the request goes back to other drivers.',
            confirmLabel: 'Cancel trip',
          );
          if (!ok || !context.mounted) return;
          AppState.instance.driverCancel(request, user);
          showMessage(context, 'Trip cancelled. The passenger has been notified.');
        },
      ));
    }
    // Driver and passenger can report a problem with each other.
    final otherName = isDriverOfTrip ? request.passenger : (isPassenger ? request.driver : null);
    final other = otherName == null ? null : AppState.instance.findUser(otherName);
    if (other != null && request.status != RequestStatus.pending) {
      items.add(const SizedBox(height: 10));
      items.add(SecondaryButton(
        label: 'Report a problem with ${isDriverOfTrip ? 'the passenger' : 'the driver'}',
        icon: Icons.flag_outlined,
        color: AppColors.red,
        onPressed: () => reportUserDialog(context, request, other),
      ));
    }
    if (isPassenger && request.status == RequestStatus.completed && request.driver != null) {
      final review = AppState.instance.reviewOfRequest(request.id);
      items.add(const SizedBox(height: 10));
      if (review == null) {
        items.add(PrimaryButton(
          label: 'Rate your driver',
          icon: Icons.star_outline,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.review, arguments: request.id),
        ));
      } else {
        items.add(AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your review', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              RatingStars(rating: review.rating.toDouble()),
              if (review.comment.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(review.comment),
              ],
            ],
          ),
        ));
      }
    }
    return items;
  }

  Widget _cancelButton(BuildContext context, AppState state, TransportRequest request) {
    return SecondaryButton(
      label: 'Cancel request',
      icon: Icons.cancel_outlined,
      color: AppColors.red,
      onPressed: () async {
        final ok = await confirmAction(
          context,
          title: 'Cancel this request?',
          message: 'The driver will be told that you cancelled.',
          confirmLabel: 'Cancel request',
        );
        if (!ok || !context.mounted) return;
        state.cancelRequest(request);
        showMessage(context, 'Request ${request.id} cancelled.');
      },
    );
  }
}
