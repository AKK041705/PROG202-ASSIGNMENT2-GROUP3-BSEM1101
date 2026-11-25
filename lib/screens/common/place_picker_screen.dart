import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/ui_helpers.dart';
import '../../data/fare_service.dart';
import '../../data/place_data.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/responsive_body.dart';

/// Search screen for choosing a place. Returns the chosen place name to the
/// screen that opened it (data passed back with Navigator.pop).
class PlacePickerScreen extends StatefulWidget {
  const PlacePickerScreen({
    super.key,
    required this.title,
    this.allowCustom = false,
  });

  final String title;
  final bool allowCustom;

  @override
  State<PlacePickerScreen> createState() => _PlacePickerScreenState();
}

class _PlacePickerScreenState extends State<PlacePickerScreen> {
  final _searchController = TextEditingController();
  final _customNameController = TextEditingController();
  String _query = '';
  String? _anchorName;
  bool _enterCustomPlace = false;

  @override
  void dispose() {
    _searchController.dispose();
    _customNameController.dispose();
    super.dispose();
  }

  String _areaLabel(Place p) {
    switch (p.area) {
      case 'City':
        return 'Freetown';
      case 'Peninsula':
        return 'Western Area';
      case 'Lungi':
        return 'Lungi';
      case 'North':
        return 'North';
      default:
        return 'South and East';
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final results =
        kPlaces.where((p) => p.name.toLowerCase().contains(q)).toList();
    return Scaffold(
      appBar: AppTopBar(title: widget.title),
      body: SafeArea(
        child: ResponsiveBody(
          scroll: false,
          child: Column(
            children: [
              // A plain TextField, used here for searching (not inside a Form).
              TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration:
                    appInputDecoration('Search places', Icons.search).copyWith(
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 12),
              if (widget.allowCustom)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(() {
                      _enterCustomPlace = !_enterCustomPlace;
                    }),
                    icon: Icon(_enterCustomPlace
                        ? Icons.list
                        : Icons.add_location_alt_outlined),
                    label: Text(_enterCustomPlace
                        ? 'Choose a listed place'
                        : 'Can’t find it? Enter a custom place'),
                  ),
                ),
              Expanded(
                child: _enterCustomPlace
                    ? _buildCustomPlaceForm()
                    : results.isEmpty
                        ? const EmptyState(
                            icon: Icons.search_off,
                            title: 'No place found',
                            message:
                                'Try a shorter name, for example "lum" for Lumley.',
                          )
                        : ListView.separated(
                            itemCount: results.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final place = results[index];
                              return ListTile(
                                leading: Icon(Icons.place_outlined,
                                    color: AppColors.green),
                                title: Text(place.name),
                                subtitle: Text(_areaLabel(place)),
                                onTap: () => Navigator.pop(context, place.name),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomPlaceForm() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        AppTextField(
          controller: _customNameController,
          label: 'Custom place name',
          icon: Icons.place_outlined,
          hint: 'Enter the destination or pickup',
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _anchorName,
          isExpanded: true,
          hint: const Text('Choose the nearest listed location'),
          decoration: appInputDecoration(
              'Nearest listed location along the route',
              Icons.near_me_outlined),
          items: [
            for (final place in kPlaces)
              DropdownMenuItem<String>(
                value: place.name,
                child: Text(place.name, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (value) => setState(() => _anchorName = value),
        ),
        const SizedBox(height: 8),
        NoteBox(
          text:
              'The fare is estimated using the listed location as a route point, plus ${FareService.customPlaceExtraKm} km for this custom place. Choose the closest listed point along the route. This is not a live map distance.',
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () {
            final name = _customNameController.text.trim();
            final anchor = _anchorName;
            if (name.isEmpty || anchor == null) {
              showMessage(context,
                  'Enter a place name and choose the nearest listed location',
                  error: true);
              return;
            }
            if (kPlaces.any(
                (place) => place.name.toLowerCase() == name.toLowerCase())) {
              showMessage(context,
                  'That place is already in the list. Choose it from the search results.');
              return;
            }
            Navigator.pop(
              context,
              CustomPlaceSelection(name: name, anchorName: anchor),
            );
          },
          icon: const Icon(Icons.check),
          label: const Text('Use this place'),
        ),
      ],
    );
  }
}
