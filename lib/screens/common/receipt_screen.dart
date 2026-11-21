import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../services/currency_service.dart';
import '../../state/app_state.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/common_widgets.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.requestId});

  final String requestId;

  String _date(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    String two(int value) => value.toString().padLeft(2, '0');

    return '${two(date.day)} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final request = state.requestById(requestId);

    if (request == null || !request.paid || request.payAmount == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AppTopBar(title: 'Receipt'),
        body: const EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'No receipt yet',
          message: 'A receipt is available after a payment.',
        ),
      );
    }

    final passenger = state.findUser(request.passenger);
    final amount = CurrencyService.money(
      request.payAmount!,
      request.payCurrency,
    );
    final paidAt = request.paidAt ?? DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Payment receipt'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: _receipt(
                      id: request.id,
                      date: _date(paidAt),
                      passenger: passenger?.name ?? '-',
                      pickup: request.pickup,
                      destination: request.destination,
                      method: request.payMethod ?? '-',
                      amount: amount,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receipt({
    required String id,
    required String date,
    required String passenger,
    required String pickup,
    required String destination,
    required String method,
    required String amount,
  }) {
    const dark = Color(0xFF17231B);
    const secondary = Color(0xFF46554B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDCE5DE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.directions_bus_rounded,
            color: Color(0xFF16803C),
            size: 34,
          ),
          const SizedBox(height: 7),
          const Text(
            'SALONE TRANSPORT HUB',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: dark,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'PAYMENT RECEIPT',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _row('Receipt No.', 'PAY-$id'),
          _row('Date', date),
          _row('Passenger', passenger),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFDCE5DE)),
          ),
          const Text(
            'JOURNEY',
            style: TextStyle(
              color: Color(0xFF16803C),
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          _location('From', pickup),
          const SizedBox(height: 9),
          _location('To', destination),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFDCE5DE)),
          ),
          _row('Payment method', method),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4ED),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  'TOTAL PAID',
                  style: TextStyle(
                    color: secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    amount,
                    style: const TextStyle(
                      color: Color(0xFF116B35),
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Color(0xFF16803C),
                size: 17,
              ),
              SizedBox(width: 6),
              Text(
                'PAYMENT SUCCESSFUL',
                style: TextStyle(
                  color: Color(0xFF116B35),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'DEMO RECEIPT',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondary,
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF46554B),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF17231B),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _location(String label, String location) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.location_on,
          color: Color(0xFF16803C),
          size: 17,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF46554B),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                location,
                style: const TextStyle(
                  color: Color(0xFF17231B),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
