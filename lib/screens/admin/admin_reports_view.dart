import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../core/date_format.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/responsive_body.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/user_dialogs.dart';

/// Administrator tab: fare issue reports, and reports about drivers and passengers.
class AdminReportsView extends StatelessWidget {
  const AdminReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final fareReports = state.reports.reversed.toList();
        final userReports = state.userReports.reversed.toList();
        return RefreshIndicator(
          color: AppColors.green,
          onRefresh: () async => state.refresh(),
          child: ResponsiveBody(
            scroll: false,
            child: ListView(
              children: [
                const SectionTitle('Fare issue reports'),
                if (fareReports.isEmpty) const NoteBox(text: 'No fare reports yet.'),
                for (final r in fareReports)
                  AppCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.reviewReport, arguments: r.id),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('${r.id}  |  ${r.mode}', style: const TextStyle(fontWeight: FontWeight.w700)),
                            ),
                            StatusChip.report(r.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(r.route, style: TextStyle(color: AppColors.textSecondary)),
                        Text(
                          'Reported: NLe ${r.reported.toStringAsFixed(1)}  |  System: ${r.systemFare}',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                const SectionTitle('Reports about drivers and passengers'),
                if (userReports.isEmpty) const NoteBox(text: 'No reports about people yet.'),
                for (final r in userReports)
                  Builder(
                    builder: (context) {
                      final reporter = state.findUser(r.reporter);
                      final subject = state.findUser(r.subject);
                      return AppCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text('${r.id}  |  ${r.requestId}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                ),
                                StatusChip(
                                  label: r.reviewed ? 'Reviewed' : 'Open',
                                  textColor: r.reviewed ? AppColors.success : AppColors.amber,
                                  background: r.reviewed ? AppColors.successTint : AppColors.amberTint,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            InfoRow('From', '${reporter?.name ?? r.reporter} (${reporter?.role.label ?? ''})'),
                            InfoRow('About', '${subject?.name ?? r.subject} (${subject?.role.label ?? ''})'),
                            InfoRow('When', DateText.full(r.time)),
                            InfoRow('What', r.text),
                            if (r.response.isNotEmpty) InfoRow('Reply', r.response),
                            Wrap(
                              spacing: 8,
                              children: [
                                if (!r.reviewed)
                                  TextButton.icon(
                                    onPressed: () async {
                                      final reply = await askForText(
                                        context,
                                        title: 'Review ${r.id}',
                                        label: 'Message to the reporter',
                                        confirmLabel: 'Mark reviewed',
                                        minLength: 3,
                                      );
                                      if (reply == null) return;
                                      state.reviewUserReport(r, reply);
                                    },
                                    icon: const Icon(Icons.check_circle_outline),
                                    label: const Text('Mark reviewed'),
                                  ),
                                if (subject != null)
                                  TextButton.icon(
                                    onPressed: () => messageUserDialog(context, subject),
                                    icon: const Icon(Icons.mail_outline),
                                    label: const Text('Message them'),
                                  ),
                                if (subject != null)
                                  TextButton.icon(
                                    onPressed: () => toggleSuspendDialog(context, subject),
                                    icon: Icon(subject.suspended ? Icons.lock_open : Icons.block,
                                        color: subject.suspended ? AppColors.green : AppColors.red),
                                    label: Text(
                                      subject.suspended ? 'Reinstate' : 'Suspend',
                                      style: TextStyle(color: subject.suspended ? AppColors.green : AppColors.red),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
