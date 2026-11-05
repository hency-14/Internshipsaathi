import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/application.dart';
import '../../models/internship.dart';
import '../../providers/session_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/ui_kit.dart';
import '../internship/internship_detail_screen.dart';

/// Lists the internships the student has applied to, newest first, with their
/// current status.
class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SessionProvider session = context.watch<SessionProvider>();
    final List<Application> apps = List<Application>.of(session.applications)
      ..sort((Application a, Application b) =>
          b.appliedAt.compareTo(a.appliedAt));

    return Scaffold(
      appBar: AppBar(title: const Text('My applications')),
      body: apps.isEmpty
          ? const _EmptyApplications()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: apps.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) {
                final Application app = apps[index];
                final Internship? internship =
                    session.internshipById(app.internshipId);
                if (internship == null) return const SizedBox.shrink();
                return _ApplicationTile(application: app, internship: internship);
              },
            ),
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  final Application application;
  final Internship internship;
  const _ApplicationTile({required this.application, required this.internship});

  Color _statusColor(ApplicationStatus status, ColorScheme scheme) {
    return switch (status) {
      ApplicationStatus.accepted => const Color(0xFF16A34A),
      ApplicationStatus.shortlisted => const Color(0xFF2563EB),
      ApplicationStatus.rejected => scheme.error,
      ApplicationStatus.underReview => const Color(0xFFD97706),
      ApplicationStatus.applied => scheme.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final Color statusColor = _statusColor(application.status, scheme);

    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CompanyMonogram(company: internship.company, size: 44),
        title: Text(internship.title,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${internship.company} · Applied '
            '${DateFormat.yMMMd().format(application.appliedAt)}',
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            application.status.label,
            style: text.labelMedium
                ?.copyWith(color: statusColor, fontWeight: FontWeight.w600),
          ),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                InternshipDetailScreen(internshipId: internship.id),
          ),
        ),
      ),
    );
  }
}

class _EmptyApplications extends StatelessWidget {
  const _EmptyApplications();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.assignment_outlined,
      title: 'No applications yet',
      message:
          'Apply to internships from your matches and they will appear here.',
    );
  }
}
