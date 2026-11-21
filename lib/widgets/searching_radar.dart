import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import 'fare_tile.dart';

/// Pulsing rings around the vehicle icon, shown while a request waits for a driver.
/// The rings fade by blending into the background colour (no transparency layers).
class SearchingRadar extends StatefulWidget {
  const SearchingRadar({super.key, required this.mode});

  final String mode;

  @override
  State<SearchingRadar> createState() => _SearchingRadarState();
}

class _SearchingRadarState extends State<SearchingRadar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _ring(double phase) {
    final t = (_controller.value + phase) % 1.0;
    final size = 56 + 110 * t;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Color.lerp(AppColors.green, AppColors.surface, t)!, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              _ring(0.0),
              _ring(0.33),
              _ring(0.66),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                child: Icon(modeIcon(widget.mode), color: Colors.white, size: 28),
              ),
            ],
          );
        },
      ),
    );
  }
}
