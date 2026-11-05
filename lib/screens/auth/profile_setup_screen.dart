import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/student.dart';
import '../../providers/session_provider.dart';
import '../../widgets/profile_editor.dart';

/// Shown right after sign-up, before the student can be matched. Collecting
/// skills, location, interests and goals here is what lets the engine produce
/// meaningful recommendations on the very first visit to Home.
class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SessionProvider session = context.watch<SessionProvider>();
    final Student? student = session.student;
    if (student == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up your profile'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          const _IntroBanner(),
          Expanded(
            child: ProfileEditor(
              initial: student,
              submitLabel: 'Find my matches',
              onSubmit: (Student updated) async {
                await context.read<SessionProvider>().saveProfile(updated);
                return true; // AuthGate moves on to Home automatically
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroBanner extends StatelessWidget {
  const _IntroBanner();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.primaryContainer,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Text(
        'Tell us about yourself so we can match you with the right '
        'internships. You can edit this anytime.',
        style: TextStyle(color: scheme.onPrimaryContainer),
      ),
    );
  }
}
