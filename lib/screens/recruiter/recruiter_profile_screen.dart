import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/recruiter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recruiter_provider.dart';
import '../../widgets/theme_toggle.dart';
import '../../widgets/ui_kit.dart';
import 'recruiter_edit_profile_screen.dart';

/// The recruiter's company profile: company details, contact, appearance, and
/// sign-out.
class RecruiterProfileScreen extends StatelessWidget {
  const RecruiterProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RecruiterProvider provider = context.watch<RecruiterProvider>();
    final Recruiter? recruiter = provider.recruiter;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    if (recruiter == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          _CompanyHero(recruiter: recruiter),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        _row(context, Icons.person_outline, 'Contact',
                            recruiter.name),
                        _divider(scheme),
                        _row(context, Icons.mail_outline, 'Email',
                            recruiter.email),
                        if (recruiter.website.isNotEmpty) ...<Widget>[
                          _divider(scheme),
                          _row(context, Icons.link_outlined, 'Website',
                              recruiter.website),
                        ],
                        if (recruiter.about.isNotEmpty) ...<Widget>[
                          _divider(scheme),
                          _row(context, Icons.notes_outlined, 'About',
                              recruiter.about),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.work_outline,
                              color: scheme.onPrimaryContainer),
                        ),
                        const SizedBox(width: 14),
                        Text('${provider.postings.length}',
                            style: text.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(width: 8),
                        Text('active postings',
                            style: text.bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(ColorScheme scheme) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Divider(
            height: 1, color: scheme.outlineVariant.withValues(alpha: 0.6)),
      );

  Widget _row(
      BuildContext context, IconData icon, String label, String value) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 20, color: scheme.primary),
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
    );
  }
}

class _CompanyHero extends StatelessWidget {
  final Recruiter recruiter;
  const _CompanyHero({required this.recruiter});

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
                  Text('Company',
                      style: text.titleLarge?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  const ThemeToggleButton(),
                  IconButton(
                    tooltip: 'Edit profile',
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const RecruiterEditProfileScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white,
                child: Icon(Icons.business,
                    size: 40, color: const Color(0xFF6366F1)),
              ),
              const SizedBox(height: 12),
              Text(
                recruiter.companyName.isEmpty
                    ? 'Your company'
                    : recruiter.companyName,
                textAlign: TextAlign.center,
                style: text.titleLarge?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w800),
              ),
              if (recruiter.location.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.place_outlined,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 3),
                    Text(recruiter.location,
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
}
