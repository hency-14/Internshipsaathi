import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/match_result.dart';
import '../../providers/session_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/animations.dart';
import '../../widgets/match_card.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/theme_toggle.dart';
import '../../widgets/ui_kit.dart';
import '../internship/internship_detail_screen.dart';

/// The home tab: internships ranked best-first for the signed-in student by
/// the matching engine. This is the core value of InternshipSaathi.
class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SessionProvider session = context.watch<SessionProvider>();
    final List<MatchResult> matches = session.matches;
    final String? firstName = session.student?.name.split(' ').first;
    final int appliedCount = matches
        .where((MatchResult m) => session.hasApplied(m.internship.id))
        .length;

    return Scaffold(
      body: Column(
        children: <Widget>[
          GradientHeader(
            title: firstName == null || firstName.isEmpty
                ? 'Your matches'
                : 'Hi $firstName 👋',
            subtitle: 'Internships picked for your profile, best first.',
            actions: const <Widget>[ThemeToggleButton()],
            child: Row(
              children: <Widget>[
                HeaderStat(
                    icon: Icons.auto_awesome, label: '${matches.length} matches'),
                const SizedBox(width: 10),
                HeaderStat(
                    icon: Icons.check_circle_outline,
                    label: '$appliedCount applied'),
              ],
            ),
          ),
          Expanded(
            child: session.loading
                ? const SkeletonCardList()
                : RefreshIndicator(
                    onRefresh: session.refresh,
                    child: matches.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const <Widget>[
                              SizedBox(height: 420, child: _EmptyMatches()),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            itemCount: matches.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 14),
                            itemBuilder: (BuildContext context, int index) {
                              final MatchResult result = matches[index];
                              return AnimatedEntrance(
                                index: index,
                                child: MatchCard(
                                  result: result,
                                  applied:
                                      session.hasApplied(result.internship.id),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => InternshipDetailScreen(
                                        internshipId: result.internship.id,
                                      ),
                                    ),
                                  ),
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

class _EmptyMatches extends StatelessWidget {
  const _EmptyMatches();

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off_outlined,
      title: 'No matches yet',
      message: AppConfig.useFirebase
          ? 'No internships are available yet. Seed the catalog from the '
              'Profile tab, or complete your profile.'
          : 'Complete your profile so we can find matches for you.',
    );
  }
}
