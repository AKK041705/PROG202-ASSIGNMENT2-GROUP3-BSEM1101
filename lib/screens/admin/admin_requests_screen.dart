import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/request_card.dart';
import '../../widgets/responsive_body.dart';

/// Every request, with filters by status. Opened from the dashboard numbers.
class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key, this.initialFilter});

  final String? initialFilter;

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  late String _filter = widget.initialFilter ?? 'All';

  static const List<String> _filters = [
    'All',
    'Pending',
    'Awaiting Passenger',
    'Confirmed',
    'Completed',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return Scaffold(
      appBar: AppTopBar(title: _filter == 'All' ? 'All requests' : '$_filter requests'),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: state,
          builder: (context, _) {
            final items = state.requests.reversed
                .where((r) => _filter == 'All' || r.status.label == _filter)
                .toList();
            return ResponsiveBody(
              scroll: false,
              child: Column(
                children: [
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final f in _filters)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(f),
                              selected: _filter == f,
                              showCheckmark: false,
                              selectedColor: AppColors.green,
                              backgroundColor: AppColors.surface,
                              side: BorderSide(color: AppColors.border),
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _filter == f ? Colors.white : AppColors.textPrimary,
                              ),
                              onSelected: (_) => setState(() => _filter = f),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: items.isEmpty
                        ? const EmptyState(
                            icon: Icons.inbox_outlined,
                            title: 'Nothing here',
                            message: 'No requests match this filter.',
                          )
                        : ListView(
                            children: [
                              for (final r in items)
                                RequestCard(
                                  request: r,
                                  subtitle: 'Passenger: ${state.findUser(r.passenger)?.name ?? r.passenger}'
                                      '${r.driver == null ? '' : '  |  Driver: ${state.findUser(r.driver!)?.name ?? r.driver}'}',
                                  onTap: () => Navigator.pushNamed(context, AppRoutes.requestDetails, arguments: r.id),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
