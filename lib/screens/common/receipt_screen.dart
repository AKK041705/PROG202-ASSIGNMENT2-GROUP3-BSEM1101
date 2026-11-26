import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    String two(int value) => value.toString().padLeft(2, '0');

    return '${two(date.day)} ${months[date.month - 1]} ${date.year}';
  }

  String _time(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.hour)}:${two(date.minute)}';
  }

  Future<void> _copyReceipt(BuildContext context, {
    required String receiptNumber,
    required String bookingReference,
    required String passenger,
    required String pickup,
    required String destination,
    required String date,
    required String time,
    required String method,
    required String amount,
  }) async {
    final receiptText = '''
SALONE TRANSPORT HUB
PAYMENT RECEIPT

Receipt No.: $receiptNumber
Booking reference: $bookingReference
Passenger: $passenger
Date paid: $date at $time
From: $pickup
To: $destination
Payment method: $method
Total paid: $amount
Payment status: PAID

Please keep this receipt for your records.
''';

    await Clipboard.setData(ClipboardData(text: receiptText));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt details copied to clipboard')),
      );
    }
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
    final passengerName = passenger?.name ?? 'Passenger';
    final amount = CurrencyService.money(
      request.payAmount!,
      request.payCurrency,
    );
    final paidAt = request.paidAt ?? DateTime.now();
    final date = _date(paidAt);
    final time = _time(paidAt);
    final receiptNumber = 'PAY-${request.id}';
    final bookingReference = request.id;
    final method = request.payMethod ?? 'Not recorded';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Payment receipt'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 380;
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isNarrow ? 12 : 20,
                      vertical: 16,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: _receipt(
                          receiptNumber: receiptNumber,
                          bookingReference: bookingReference,
                          date: date,
                          time: time,
                          passenger: passengerName,
                          pickup: request.pickup,
                          destination: request.destination,
                          method: method,
                          amount: amount,
                          onCopy: () => _copyReceipt(
                            context,
                            receiptNumber: receiptNumber,
                            bookingReference: bookingReference,
                            passenger: passengerName,
                            pickup: request.pickup,
                            destination: request.destination,
                            date: date,
                            time: time,
                            method: method,
                            amount: amount,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isNarrow ? 12 : 20,
                    8,
                    isNarrow ? 12 : 20,
                    12,
                  ),
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
            );
          },
        ),
      ),
    );
  }

  Widget _receipt({
    required String receiptNumber,
    required String bookingReference,
    required String date,
    required String time,
    required String passenger,
    required String pickup,
    required String destination,
    required String method,
    required String amount,
    required VoidCallback onCopy,
  }) {
    const green = Color(0xFF16803C);
    const dark = Color(0xFF17231B);
    const secondary = Color(0xFF46554B);
    const border = Color(0xFFDCE5DE);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.directions_bus_rounded, color: green, size: 36),
          const SizedBox(height: 8),
          const Text(
            'SALONE TRANSPORT HUB',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: dark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'PASSENGER PAYMENT RECEIPT',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 18),
          _row('Receipt No.', receiptNumber),
          _row('Booking reference', bookingReference),
          _row('Date paid', date),
          _row('Time paid', time),
          _row('Passenger', passenger),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: border),
          ),
          const Text(
            'JOURNEY DETAILS',
            style: TextStyle(
              color: green,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _location('From', pickup),
          const SizedBox(height: 12),
          _location('To', destination),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: border),
          ),
          _row('Payment method', method),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4ED),
              borderRadius: BorderRadius.circular(10),
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
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    amount,
                    style: const TextStyle(
                      color: Color(0xFF116B35),
                      fontSize: 29,
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
              Icon(Icons.check_circle, color: green, size: 18),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'PAYMENT RECORDED',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF116B35),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep this receipt for your records.',
            textAlign: TextAlign.center,
            style: TextStyle(color: secondary, fontSize: 10),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onCopy,
            icon: const Icon(Icons.copy_outlined, size: 17),
            label: const Text('Copy receipt details'),
            style: OutlinedButton.styleFrom(
              foregroundColor: green,
              side: const BorderSide(color: border),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'SALONE TRANSPORT HUB • DEMO RECEIPT',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondary,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF46554B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              style: const TextStyle(
                color: Color(0xFF17231B),
                fontSize: 12,
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
        const Icon(Icons.location_on, color: Color(0xFF16803C), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF46554B),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                location,
                softWrap: true,
                style: const TextStyle(
                  color: Color(0xFF17231B),
                  fontSize: 13,
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
