import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/internship.dart';
import '../../models/match_result.dart';
import '../../providers/session_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/ui_kit.dart';

/// Full view of one internship: description, requirements, and — crucially —
/// *why* it matched, shown as a per-dimension breakdown. Students can apply
/// from here.
class InternshipDetailScreen extends StatelessWidget {
  final String internshipId;
  const InternshipDetailScreen({super.key, required this.internshipId});

  @override
  Widget build(BuildContext context) {
    final SessionProvider session = context.watch<SessionProvider>();
    final Internship? internship = session.internshipById(internshipId);

    if (internship == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Internship not found.')),
      );
    }

    final MatchResult match = session.matchFor(internship);
    final bool applied = session.hasApplied(internship.id);
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: <Widget>[
          _DetailHero(internship: internship, match: match),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: <Widget>[
                _FactsCard(internship: internship),
                const SizedBox(height: 24),
                const SectionHeading(
                    title: 'Why this matched you', icon: Icons.insights_outlined),
                const SizedBox(height: 14),
                _MatchBreakdown(match: match),
                const SizedBox(height: 24),
                const SectionHeading(
                    title: 'Required skills',
                    icon: Icons.checklist_rtl_outlined),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: internship.requiredSkills.map((String skill) {
                    final bool have = match.matchedSkills
                        .map((String s) => s.toLowerCase())
                        .contains(skill.toLowerCase());
                    return Chip(
                      avatar: Icon(
                        have ? Icons.check_circle : Icons.circle_outlined,
                        size: 18,
                        color: have ? scheme.primary : scheme.outline,
                      ),
                      label: Text(
                        skill,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontWeight:
                              have ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      backgroundColor: have
                          ? scheme.primaryContainer.withValues(alpha: 0.55)
                          : scheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const SectionHeading(
                    title: 'About the role', icon: Icons.description_outlined),
                const SizedBox(height: 10),
                Text(internship.description,
                    style: text.bodyMedium?.copyWith(height: 1.55)),
                const SizedBox(height: 16),
                Text(
                  'Posted ${DateFormat.yMMMd().format(internship.postedAt)}',
                  style:
                      text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.5)),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: applied
                ? FilledButton.tonalIcon(
                    onPressed: null,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Already applied'),
                  )
                : GradientButton(
                    label: 'Apply now',
                    icon: Icons.send_outlined,
                    onPressed: () async {
                      await context
                          .read<SessionProvider>()
                          .apply(internship);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(const SnackBar(
                              content: Text('Application submitted! 🎉')));
                      }
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

/// Gradient hero with a back button, company monogram, role title and a white
/// circular score badge.
class _DetailHero extends StatelessWidget {
  final Internship internship;
  final MatchResult match;
  const _DetailHero({required this.internship, required this.match});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final String letter = internship.company.trim().isEmpty
        ? '?'
        : internship.company.trim().characters.first.toUpperCase();
    return HeroGradientBox(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Text(internship.company,
                      style: text.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: Text(letter,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6366F1))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(internship.title,
                          style: text.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 12),
                    _ScoreBadge(score: match.score, tier: match.tier),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final double score;
  final String tier;
  const _ScoreBadge({required this.score, required this.tier});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
              color: Colors.white, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: RichText(
            text: TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: score.round().toString(),
                  style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 24,
                      fontWeight: FontWeight.w800),
                ),
                const TextSpan(
                  text: '%',
                  style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('match',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _FactsCard extends StatelessWidget {
  final Internship internship;
  const _FactsCard({required this.internship});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _fact(context, Icons.place_outlined, 'Location',
                internship.location),
            _fact(context, Icons.work_outline, 'Mode',
                internship.workMode.label),
            _fact(context, Icons.schedule_outlined, 'Duration',
                '${internship.durationMonths} mo'),
            _fact(
              context,
              Icons.currency_rupee,
              'Stipend',
              internship.stipend > 0 ? '${internship.stipend}' : 'Unpaid',
            ),
          ],
        ),
      ),
    );
  }

  Widget _fact(
      BuildContext context, IconData icon, String label, String value) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: <Widget>[
          Icon(icon, size: 22, color: scheme.primary),
          const SizedBox(height: 6),
          Text(value,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  text.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _MatchBreakdown extends StatelessWidget {
  final MatchResult match;
  const _MatchBreakdown({required this.match});

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<MatchDimension, double>> entries =
        match.breakdown.entries.toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Column(
          children: entries.map((MapEntry<MatchDimension, double> e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _DimensionBar(label: e.key.label, value: e.value),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _DimensionBar extends StatelessWidget {
  final String label;
  final double value; // 0–100
  const _DimensionBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final MatchPalette p = matchPalette(value, Theme.of(context).brightness);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(label,
                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            Text('${value.round()}%',
                style: text.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700, color: p.fg)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            minHeight: 9,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(p.base),
          ),
        ),
      ],
    );
  }
}
