import 'package:flutter/material.dart';

import '../../models/match_result.dart';
import '../../models/student.dart';

/// Read-only view of a student's full profile, opened by a recruiter from the
/// applicants list. Shows everything the applicant card summarises plus their
/// interests, career goals and bio, alongside the match score for the role.
class StudentProfileScreen extends StatelessWidget {
  final Student student;
  final MatchResult match;
  const StudentProfileScreen({
    super.key,
    required this.student,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(student.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primaryContainer,
                child: Text(
                  _initials(student.name),
                  style: text.titleLarge?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(student.name,
                        style: text.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text(student.email,
                        style: text.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: <Widget>[
                Icon(Icons.insights, color: scheme.onSecondaryContainer),
                const SizedBox(width: 10),
                Text(
                  'Match for this role: ${match.score.round()}% · ${match.tier}',
                  style: text.titleSmall?.copyWith(
                      color: scheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (student.education.isNotEmpty)
            _row(context, Icons.school_outlined, 'Education', student.education),
          if (student.location.isNotEmpty)
            _row(context, Icons.place_outlined, 'Location', student.location),
          if (student.bio.isNotEmpty)
            _row(context, Icons.notes_outlined, 'Bio', student.bio),
          const SizedBox(height: 12),
          _chips(context, 'Skills', student.skills),
          _chips(context, 'Interests', student.interests),
          _chips(context, 'Career goals', student.careerGoals),
        ],
      ),
    );
  }

  Widget _row(
      BuildContext context, IconData icon, String label, String value) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label,
                    style: text.labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: text.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chips(BuildContext context, String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    final TextTheme text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                items.map((String e) => Chip(label: Text(e))).toList(),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
