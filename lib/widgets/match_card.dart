import 'package:flutter/material.dart';

import '../models/match_result.dart';
import '../utils/constants.dart';
import 'score_ring.dart';
import 'ui_kit.dart';

/// Compact card summarising one ranked internship match: a gradient company
/// monogram, the role, key facts as pills, the overall score ring and a
/// colour-coded match tier.
class MatchCard extends StatelessWidget {
  final MatchResult result;
  final bool applied;
  final VoidCallback onTap;

  const MatchCard({
    super.key,
    required this.result,
    required this.onTap,
    this.applied = false,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final internship = result.internship;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CompanyMonogram(company: internship.company),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          internship.title,
                          style: text.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          internship.company,
                          style: text.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ScoreRing(score: result.score),
                ],
              ),
              const SizedBox(height: 14),
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
                  height: 1, color: scheme.outlineVariant.withValues(alpha: 0.6)),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  TierBadge(score: result.score, label: result.tier),
                  const Spacer(),
                  if (applied)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.check_circle,
                            size: 16, color: scheme.primary),
                        const SizedBox(width: 4),
                        Text('Applied',
                            style: text.labelMedium?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w700)),
                      ],
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('View details',
                            style: text.labelMedium?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600)),
                        Icon(Icons.chevron_right,
                            size: 18, color: scheme.primary),
                      ],
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
