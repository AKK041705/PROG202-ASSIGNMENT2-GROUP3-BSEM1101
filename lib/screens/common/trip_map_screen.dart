import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/ui_helpers.dart';
import '../../data/fare_service.dart';
import '../../models/models.dart';
import '../../services/currency_service.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/status_chip.dart';

/// A stylised map of the trip with the vehicle moving along the route.
/// This is an illustration. Real GPS tracking is planned for the final project.
class TripMapScreen extends StatefulWidget {
  const TripMapScreen({super.key, required this.requestId});

  final String requestId;

  @override
  State<TripMapScreen> createState() => _TripMapScreenState();
}

class _TripMapScreenState extends State<TripMapScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _etaMinutes(TransportRequest r) {
    final km = FareService.distanceKm(r.pickup, r.destination);
    final speed = r.mode == 'Okada' ? 25.0 : 35.0;
    final minutes = (km / speed * 60).ceil();
    return minutes < 2 ? 2 : minutes;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final request = state.requestById(widget.requestId);
        if (request == null) {
          return Scaffold(
            appBar: const AppTopBar(title: 'Track trip'),
            body: const EmptyState(
              icon: Icons.map_outlined,
              title: 'Trip not found',
              message: 'This request is no longer available.',
            ),
          );
        }
        final driver = request.driver == null ? null : state.findUser(request.driver!);
        final eta = _etaMinutes(request);
        return Scaffold(
          appBar: AppTopBar(title: 'Track ${request.id}'),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) => CustomPaint(
                            painter: _MapPainter(progress: _controller.value),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: _MapChip(icon: Icons.schedule, text: 'About $eta min'),
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: _MapChip(
                          icon: Icons.route,
                          text: '${FareService.distanceKm(request.pickup, request.destination)} km',
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Illustration only. Live GPS tracking will be added in the final project.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.green,
                              child: Text(driver?.initials ?? '?', style: const TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(driver?.name ?? 'Waiting for a driver',
                                      style: const TextStyle(fontWeight: FontWeight.w800)),
                                  Text(
                                    driver == null ? request.mode : '${driver.vehicle}  |  ${driver.plate}',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            StatusChip.request(request.status),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('${request.pickup} to ${request.destination}',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyService.paymentText(request.payCurrency, request.payAmount),
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => showMessage(context, 'Calling is not available in the prototype.'),
                                icon: const Icon(Icons.call_outlined),
                                label: const Text('Call'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => showMessage(context, 'Messaging is not available in the prototype.'),
                                icon: const Icon(Icons.chat_bubble_outline),
                                label: const Text('Message'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapChip extends StatelessWidget {
  const _MapChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.green),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Draws city blocks, the route, the two markers and the moving vehicle.
class _MapPainter extends CustomPainter {
  _MapPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Roads (background) and city blocks
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = AppColors.border);
    final block = Paint()..color = AppColors.background;
    const cell = 84.0;
    for (var x = 0.0; x < w; x += cell) {
      for (var y = 0.0; y < h; y += cell) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x + 6, y + 6, cell - 12, cell - 12), const Radius.circular(8)),
          block,
        );
      }
    }

    // Route
    final a = Offset(w * 0.16, h * 0.80);
    final b = Offset(w * 0.84, h * 0.22);
    final route = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(a.dx, h * 0.52)
      ..lineTo(w * 0.52, h * 0.52)
      ..lineTo(w * 0.52, b.dy)
      ..lineTo(b.dx, b.dy);
    canvas.drawPath(
      route,
      Paint()
        ..color = AppColors.info
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Pickup and destination markers
    canvas.drawCircle(a, 12, Paint()..color = AppColors.surface);
    canvas.drawCircle(a, 7, Paint()..color = AppColors.info);
    canvas.drawCircle(b, 15, Paint()..color = AppColors.surface);
    canvas.drawCircle(b, 10, Paint()..color = AppColors.green);
    canvas.drawCircle(b, 4, Paint()..color = Colors.white);

    // Vehicle driving along the route
    for (final metric in route.computeMetrics()) {
      final spot = metric.getTangentForOffset(metric.length * progress);
      if (spot == null) continue;
      canvas.save();
      canvas.translate(spot.position.dx, spot.position.dy);
      canvas.rotate(spot.vector.direction);
      final body = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-15, -9, 30, 18),
        const Radius.circular(6),
      );
      canvas.drawRRect(body, Paint()..color = AppColors.greenDark);
      canvas.drawRRect(body, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
      canvas.drawRect(const Rect.fromLTWH(2, -6, 8, 12), Paint()..color = Colors.white);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.progress != progress;
}
