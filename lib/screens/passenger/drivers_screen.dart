import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../core/ui_helpers.dart';
import '../../data/fare_service.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/fare_tile.dart';
import '../../widgets/rating_widgets.dart';
import '../../widgets/responsive_body.dart';

/// Find a driver: search by name, plate or vehicle, and filter by vehicle type,
/// minimum rating and whether the driver has reviews. Tap a driver to open the profile.
class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _type = 'All types';
  double _minRating = 0;
  bool _onlyReviewed = false;
  String _sort = 'Best rated';

  static const List<String> _sorts = ['Best rated', 'Most trips', 'Name (A to Z)'];
  static const List<double> _ratings = [0, 3, 4, 4.5];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clear() {
    setState(() {
      _searchController.clear();
      _query = '';
      _type = 'All types';
      _minRating = 0;
      _onlyReviewed = false;
      _sort = 'Best rated';
    });
  }

  ChoiceChip _chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: AppColors.green,
      backgroundColor: AppColors.surface,
      side: BorderSide(color: AppColors.border),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: selected ? Colors.white : AppColors.textPrimary,
      ),
      onSelected: (_) => onTap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return Scaffold(
      appBar: const AppTopBar(title: 'Find drivers'),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: state,
          builder: (context, _) {
            final q = _query.trim().toLowerCase();
            var drivers = state.drivers.where((d) => d.verified && !d.suspended).where((d) {
              if (_type != 'All types' && d.driverType != _type) return false;
              final rating = state.averageRating(d.username);
              if (_onlyReviewed && rating == null) return false;
              if (_minRating > 0 && (rating == null || rating < _minRating)) return false;
              if (q.isEmpty) return true;
              return d.name.toLowerCase().contains(q) ||
                  (d.vehicle ?? '').toLowerCase().contains(q) ||
                  (d.plate ?? '').toLowerCase().contains(q);
            }).toList();

            drivers.sort((a, b) {
              if (_sort == 'Name (A to Z)') return a.name.compareTo(b.name);
              if (_sort == 'Most trips') {
                return state.completedTripsOf(b.username).compareTo(state.completedTripsOf(a.username));
              }
              final ra = state.averageRating(a.username) ?? 0;
              final rb = state.averageRating(b.username) ?? 0;
              final byRating = rb.compareTo(ra);
              return byRating != 0
                  ? byRating
                  : state.reviewsForDriver(b.username).length.compareTo(state.reviewsForDriver(a.username).length);
            });

            return ResponsiveBody(
              scroll: false,
              child: ListView(
                children: [
                  // A plain TextField for searching.
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: appInputDecoration('Search by name, plate or vehicle', Icons.search),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final t in ['All types', ...FareService.driverTypes])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _chip(t, _type == t, () => setState(() => _type = t)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final r in _ratings)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _chip(
                              r == 0 ? 'Any rating' : '${r == r.roundToDouble() ? r.toInt() : r}+ stars',
                              _minRating == r,
                              () => setState(() => _minRating = r),
                            ),
                          ),
                        _chip('Has reviews', _onlyReviewed, () => setState(() => _onlyReviewed = !_onlyReviewed)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${drivers.length} driver(s) found',
                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ),
                      DropdownButton<String>(
                        value: _sort,
                        underline: const SizedBox.shrink(),
                        items: [for (final s in _sorts) DropdownMenuItem(value: s, child: Text(s))],
                        onChanged: (v) => setState(() => _sort = v ?? _sort),
                      ),
                      TextButton(onPressed: _clear, child: const Text('Reset')),
                    ],
                  ),
                  if (drivers.isEmpty)
                    const EmptyState(
                      icon: Icons.person_search_outlined,
                      title: 'No drivers match',
                      message: 'Try a different search or reset the filters.',
                    ),
                  for (final d in drivers) _driverCard(context, state, d),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _driverCard(BuildContext context, AppState state, AppUser d) {
    final rating = state.averageRating(d.username);
    final reviews = state.reviewsForDriver(d.username).length;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: () => Navigator.pushNamed(context, AppRoutes.driverProfile, arguments: d.username),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.green,
            child: Icon(modeIcon(d.driverType ?? ''), color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  '${d.driverType}  |  ${d.vehicle}  |  ${d.plate}',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    RatingStars(rating: rating ?? 0, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      rating == null ? 'No reviews yet' : '${rating.toStringAsFixed(1)} ($reviews)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${state.completedTripsOf(d.username)} trips',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
