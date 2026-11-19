import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../models/models.dart';
import '../../services/phone_service.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/responsive_body.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/user_dialogs.dart';

/// All passengers: contact them, or suspend and reinstate accounts.
class AdminPassengersScreen extends StatelessWidget {
  const AdminPassengersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return Scaffold(
      appBar: const AppTopBar(title: 'Passengers'),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: state,
          builder: (context, _) {
            final people = state.passengers;
            return ResponsiveBody(
              scroll: false,
              child: people.isEmpty
                  ? const EmptyState(
                      icon: Icons.people_outline,
                      title: 'No passengers yet',
                      message: 'Passengers who register will appear here.',
                    )
                  : ListView(
                      children: [for (final p in people) _PassengerCard(passenger: p)],
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _PassengerCard extends StatelessWidget {
  const _PassengerCard({required this.passenger});

  final AppUser passenger;

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final trips = state.requestsOfPassenger(passenger.username);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.green,
                child: Text(passenger.initials, style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(passenger.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text('@${passenger.username}', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              if (passenger.suspended)
                StatusChip(label: 'Suspended', textColor: Colors.white, background: AppColors.red)
              else
                StatusChip(label: 'Active', textColor: AppColors.success, background: AppColors.successTint),
            ],
          ),
          const SizedBox(height: 8),
          InfoRow('Phone', PhoneService.display(passenger.phone)),
          InfoRow('Country', passenger.country),
          InfoRow('Requests', '${trips.length}  (${trips.where((t) => t.status == RequestStatus.completed).length} completed)'),
          if (passenger.suspended) InfoRow('Reason', passenger.suspendReason),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: () => messageUserDialog(context, passenger),
                icon: const Icon(Icons.mail_outline),
                label: const Text('Message'),
              ),
              TextButton.icon(
                onPressed: () => toggleSuspendDialog(context, passenger),
                icon: Icon(passenger.suspended ? Icons.lock_open : Icons.block,
                    color: passenger.suspended ? AppColors.green : AppColors.red),
                label: Text(
                  passenger.suspended ? 'Reinstate' : 'Suspend',
                  style: TextStyle(color: passenger.suspended ? AppColors.green : AppColors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
