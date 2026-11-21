import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../services/currency_service.dart';
import '../../state/app_state.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/common_widgets.dart';

/// Demo payment: choose a method, confirm, see processing, then success.
/// No real money is taken.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.requestId});

  final String requestId;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const List<_Method> _methods = [
    _Method(
      'Cash to driver',
      Icons.payments_outlined,
      'Pay the driver when you travel',
    ),
    _Method(
      'Mobile money (demo)',
      Icons.phone_android,
      'Demo only, no real payment',
    ),
    _Method(
      'Card (demo)',
      Icons.credit_card,
      'Demo only, no real payment',
    ),
  ];

  String _method = _methods.first.name;

  Future<void> _pay() async {
    final state = AppState.instance;
    final request = state.requestById(widget.requestId);

    if (request == null || request.payAmount == null) return;

    final amount = CurrencyService.money(
      request.payAmount!,
      request.payCurrency,
    );

    // 1. Confirm payment
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Confirm payment',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              amount,
              style: TextStyle(
                color: AppColors.green,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            InfoRow('Payment method', _method),
            const SizedBox(height: 6),
            InfoRow(
              'Trip',
              '${request.pickup} to ${request.destination}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Yes, pay'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // 2. Processing payment
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            SizedBox(
              width: 46,
              height: 46,
              child: CircularProgressIndicator(
                color: AppColors.green,
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Processing payment',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              amount,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 1600));

    if (!mounted) return;

    Navigator.pop(context);
    state.payRequest(request, _method);

    // 3. Payment successful
    final wantsReceipt = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.successTint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 42,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment successful!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 19,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.w900,
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your demo payment has been recorded.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Would you like a receipt?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'No, thanks',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('View receipt'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (wantsReceipt == true) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.receipt,
        arguments: request.id,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final request = state.requestById(widget.requestId);

        if (request == null || request.payAmount == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: const AppTopBar(title: 'Payment'),
            body: const EmptyState(
              icon: Icons.payments_outlined,
              title: 'Nothing to pay here',
              message:
                  'This fare is agreed with the driver, so there is no amount to pay in the app.',
            ),
          );
        }

        final amount = CurrencyService.money(
          request.payAmount!,
          request.payCurrency,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const AppTopBar(title: 'Payment'),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Amount section
                AppCard(
                  color: AppColors.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.green,
                            size: 21,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AMOUNT TO PAY',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        amount,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        request.payCurrency == 'NLe'
                            ? 'Paid in leones.'
                            : 'Paid in ${request.payCurrency}. It is not converted to leones by the app.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Trip information
                const SectionTitle('Trip information'),

                AppCard(
                  child: Column(
                    children: [
                      InfoRow(
                        'Pickup',
                        request.pickup,
                      ),
                      const Divider(height: 18),
                      InfoRow(
                        'Destination',
                        request.destination,
                      ),
                      const Divider(height: 18),
                      InfoRow(
                        'Transport',
                        request.mode,
                      ),
                      const Divider(height: 18),
                      InfoRow(
                        'Fare (NLe)',
                        request.fareText,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Payment methods
                const SectionTitle('Choose payment method'),

                for (final method in _methods)
                  AppCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    color: _method == method.name
                        ? AppColors.greenTint
                        : AppColors.surface,
                    borderColor: _method == method.name
                        ? AppColors.green
                        : AppColors.border,
                    onTap: () {
                      setState(() {
                        _method = method.name;
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: _method == method.name
                                ? AppColors.green
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            method.icon,
                            color: _method == method.name
                                ? Colors.white
                                : AppColors.textSecondary,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method.name,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                method.hint,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _method == method.name
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: _method == method.name
                              ? AppColors.green
                              : AppColors.textSecondary,
                          size: 23,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Demo payment notice
                NoteBox(
                  text:
                      'Demo payment: no real money is taken. Prices are set in leones. Accepting foreign currency in Sierra Leone must follow Bank of Sierra Leone rules.',
                  icon: Icons.info_outline,
                  color: AppColors.amber,
                  background: AppColors.amberTint,
                ),

                const SizedBox(height: 18),

                PrimaryButton(
                  label: 'Pay $amount',
                  icon: Icons.lock_outline,
                  onPressed: _pay,
                ),

                const SizedBox(height: 12),

                Center(
                  child: Text(
                    'Secure demo payment',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
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

class _Method {
  const _Method(this.name, this.icon, this.hint);

  final String name;
  final IconData icon;
  final String hint;
}
