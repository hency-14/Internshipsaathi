import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/student.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/theme_toggle.dart';
import '../../widgets/ui_kit.dart';
import 'edit_profile_screen.dart';

/// Shows the student's profile and gives access to editing, (optional)
/// Firestore seeding, appearance settings, and sign-out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SessionProvider session = context.watch<SessionProvider>();
    final Student? student = session.student;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    if (student == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          _ProfileHero(student: student),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: <Widget>[
                if (student.education.isNotEmpty ||
                    student.bio.isNotEmpty) ...<Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (student.education.isNotEmpty)
                            _InfoRow(
                                icon: Icons.school_outlined,
                                text: student.education),
                          if (student.education.isNotEmpty &&
                              student.bio.isNotEmpty)
                            const SizedBox(height: 10),
                          if (student.bio.isNotEmpty)
                            _InfoRow(
                                icon: Icons.notes_outlined, text: student.bio),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _ChipSection(
                    title: 'Skills',
                    icon: Icons.code,
                    items: student.skills),
                _ChipSection(
                    title: 'Interests',
                    icon: Icons.interests_outlined,
                    items: student.interests),
                _ChipSection(
                    title: 'Career goals',
                    icon: Icons.flag_outlined,
                    items: student.careerGoals),
                const SizedBox(height: 8),

                // In Firebase mode, offer a one-tap way to populate an empty
                // catalog.
                if (AppConfig.useFirebase &&
                    session.internships.isEmpty) ...<Widget>[
                  OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<SessionProvider>().seedCatalog();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Sample internships added.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Seed sample internships'),
                  ),
                  const SizedBox(height: 16),
                ],

                const AppearanceCard(),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.error,
                    side: BorderSide(
                        color: scheme.error.withValues(alpha: 0.5)),
                  ),
                  onPressed: () => context.read<AuthProvider>().signOut(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '${AppConfig.appName} · v1.0',
                    style: text.labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final Student student;
  const _ProfileHero({required this.student});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return HeroGradientBox(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 8, 22),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text('Profile',
                      style: text.titleLarge?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  const ThemeToggleButton(),
                  IconButton(
                    tooltip: 'Edit profile',
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white,
                child: Text(
                  _initials(student.name),
                  style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 30,
                      fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 12),
              Text(student.name,
                  style: text.titleLarge?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w800)),
              Text(student.email,
                  style: text.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85))),
              if (student.location.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.place_outlined,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 3),
                    Text(student.location,
                        style: text.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9))),
                  ],
                ),
              ],
            ],
          ),
        ),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _ChipSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  const _ChipSection(
      {required this.title, required this.icon, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionHeading(title: title, icon: icon),
          const SizedBox(height: 10),
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
}
