import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/internship.dart';
import '../../providers/recruiter_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/animations.dart';
import '../../widgets/score_ring.dart';
import '../../widgets/ui_kit.dart';
import 'student_profile_screen.dart';

/// Shows everyone who applied to a posting, ranked by match score, each with
/// their profile and a control to move them through the hiring pipeline
/// (applied → under review → shortlisted → accepted/rejected). The list is
/// live — new applications and status changes appear without a reload.
class ApplicantsScreen extends StatefulWidget {
  final Internship internship;
  const ApplicantsScreen({super.key, required this.internship});

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  late final Stream<List<Applicant>> _stream;

  @override
  void initState() {
    super.initState();
    _stream =
        context.read<RecruiterProvider>().applicantsStream(widget.internship);
  }

  Future<void> _setStatus(Applicant applicant, ApplicationStatus status) async {
    await context
        .read<RecruiterProvider>()
        .setApplicationStatus(applicant.application, status);
    // The stream pushes the updated list automatically.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Applicant>>(
        stream: _stream,
        builder: (BuildContext context,
            AsyncSnapshot<List<Applicant>> snapshot) {
          final List<Applicant> applicants = snapshot.data ?? <Applicant>[];
          return Column(
            children: <Widget>[
              GradientHeader(
                leading: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                title: 'Applicants',
                subtitle: widget.internship.title,
                child: Row(
                  children: <Widget>[
                    HeaderStat(
                        icon: Icons.people_alt_outlined,
                        label: snapshot.hasData
                            ? '${applicants.length} total'
                            : '…'),
                  ],
                ),
              ),
              Expanded(
                child: !snapshot.hasData
                    ? const Center(child: CircularProgressIndicator())
                    : applicants.isEmpty
                        ? const _EmptyApplicants()
                        : ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            itemCount: applicants.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 14),
                            itemBuilder: (BuildContext context, int index) =>
                                AnimatedEntrance(
                              index: index,
                              child: _ApplicantCard(
                                applicant: applicants[index],
                                onStatusChanged: (ApplicationStatus s) =>
                                    _setStatus(applicants[index], s),
                              ),
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final Applicant applicant;
  final ValueChanged<ApplicationStatus> onStatusChanged;
  const _ApplicantCard(
      {required this.applicant, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final student = applicant.student;

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => StudentProfileScreen(
              student: applicant.student,
              match: applicant.match,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CompanyMonogram(company: student.name, size: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(student.name,
                            style: text.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(student.email,
                            style: text.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant)),
                        if (student.location.isNotEmpty)
                          Text('${student.location} · ${student.education}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ScoreRing(score: applicant.match.score, size: 52),
                ],
              ),
              const SizedBox(height: 12),
              if (applicant.match.matchedSkills.isNotEmpty) ...<Widget>[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: applicant.match.matchedSkills
                      .map((String s) => Chip(
                            label: Text(s),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
              Divider(
                  height: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.6)),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Icon(Icons.schedule,
                      size: 14, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Applied ${DateFormat.yMMMd().format(applicant.application.appliedAt)}',
                      style: text.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                  _StatusDropdown(
                    value: applicant.application.status,
                    onChanged: onStatusChanged,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A status pill that opens a menu to advance the applicant through the
/// pipeline, colour-coded by stage.
class _StatusDropdown extends StatelessWidget {
  final ApplicationStatus value;
  final ValueChanged<ApplicationStatus> onChanged;
  const _StatusDropdown({required this.value, required this.onChanged});

  Color _color(ApplicationStatus s, ColorScheme scheme) => switch (s) {
        ApplicationStatus.accepted => const Color(0xFF16A34A),
        ApplicationStatus.shortlisted => const Color(0xFF2563EB),
        ApplicationStatus.rejected => scheme.error,
        ApplicationStatus.underReview => const Color(0xFFD97706),
        ApplicationStatus.applied => scheme.onSurfaceVariant,
      };

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color c = _color(value, scheme);
    return PopupMenuButton<ApplicationStatus>(
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (_) => ApplicationStatus.values
          .map((ApplicationStatus s) => PopupMenuItem<ApplicationStatus>(
                value: s,
                child: Text(s.label),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(value.label,
                style: TextStyle(
                    color: c, fontWeight: FontWeight.w700, fontSize: 12.5)),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 18, color: c),
          ],
        ),
      ),
    );
  }
}

class _EmptyApplicants extends StatelessWidget {
  const _EmptyApplicants();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.people_outline,
      title: 'No applicants yet',
      message:
          'When students apply to this posting, they will show up here, '
          'ranked by how well they match.',
    );
  }
}
