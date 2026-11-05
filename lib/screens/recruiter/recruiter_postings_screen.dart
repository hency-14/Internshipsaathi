import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/internship.dart';
import '../../providers/recruiter_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/animations.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/ui_kit.dart';
import 'applicants_screen.dart';
import 'post_internship_screen.dart';

/// A recruiter's dashboard: the internships they've posted, each with its
/// applicant count, plus actions to add, edit, view applicants, or delete.
class RecruiterPostingsScreen extends StatelessWidget {
  const RecruiterPostingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RecruiterProvider provider = context.watch<RecruiterProvider>();
    final List<Internship> postings = provider.postings;
    final String company = provider.recruiter?.companyName ?? '';
    final int totalApplicants = postings.fold<int>(
        0, (int sum, Internship i) => sum + provider.applicantCount(i.id));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const PostInternshipScreen(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Post internship'),
      ),
      body: Column(
        children: <Widget>[
          GradientHeader(
            title: 'My postings',
            subtitle: company.isEmpty ? 'Manage your openings' : company,
            child: Row(
              children: <Widget>[
                HeaderStat(
                    icon: Icons.work_outline,
                    label: '${postings.length} active'),
                const SizedBox(width: 10),
                HeaderStat(
                    icon: Icons.people_alt_outlined,
                    label: '$totalApplicants applicants'),
              ],
            ),
          ),
          Expanded(
            child: provider.loading
                ? const SkeletonCardList()
                : RefreshIndicator(
                    onRefresh: provider.refresh,
                    child: postings.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const <Widget>[
                              SizedBox(height: 420, child: _EmptyPostings()),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding:
                                const EdgeInsets.fromLTRB(16, 16, 16, 96),
                            itemCount: postings.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 14),
                            itemBuilder: (BuildContext context, int index) {
                              final Internship internship = postings[index];
                              return AnimatedEntrance(
                                index: index,
                                child: _PostingCard(
                                  internship: internship,
                                  applicants:
                                      provider.applicantCount(internship.id),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PostingCard extends StatelessWidget {
  final Internship internship;
  final int applicants;
  const _PostingCard({required this.internship, required this.applicants});

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Delete posting?'),
        content:
            Text('This removes "${internship.title}" and its applications.'),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (yes == true && context.mounted) {
      await context.read<RecruiterProvider>().deletePosting(internship.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ApplicantsScreen(internship: internship),
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
                  CompanyMonogram(company: internship.title, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(internship.title,
                        style: text.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: scheme.onSurfaceVariant),
                    onSelected: (String value) {
                      if (value == 'edit') {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                PostInternshipScreen(existing: internship),
                          ),
                        );
                      } else if (value == 'delete') {
                        _confirmDelete(context);
                      }
                    },
                    itemBuilder: (_) => const <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Edit'))),
                      PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.delete_outline),
                              title: Text('Delete'))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: <Widget>[
                  InfoPill(
                      icon: Icons.place_outlined, label: internship.location),
                  InfoPill(
                      icon: Icons.work_outline,
                      label: internship.workMode.label),
                  if (internship.stipend > 0)
                    InfoPill(
                        icon: Icons.currency_rupee,
                        label: '${internship.stipend}/mo'),
                ],
              ),
              const SizedBox(height: 14),
              Divider(
                  height: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.6)),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.people_alt_outlined,
                            size: 15, color: scheme.onPrimaryContainer),
                        const SizedBox(width: 6),
                        Text(
                          applicants == 1
                              ? '1 applicant'
                              : '$applicants applicants',
                          style: text.labelMedium?.copyWith(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text('View',
                      style: text.labelMedium?.copyWith(
                          color: scheme.primary, fontWeight: FontWeight.w600)),
                  Icon(Icons.chevron_right, size: 18, color: scheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPostings extends StatelessWidget {
  const _EmptyPostings();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.work_off_outlined,
      title: 'No postings yet',
      message:
          'Tap "Post internship" to create your first opening. Students will '
          'be matched to it automatically.',
    );
  }
}
