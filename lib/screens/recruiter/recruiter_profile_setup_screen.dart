import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/recruiter.dart';
import '../../providers/recruiter_provider.dart';
import '../../widgets/recruiter_profile_editor.dart';

/// Shown right after a recruiter signs up, before they can post internships.
/// Collects the company details that get stamped onto every posting.
class RecruiterProfileSetupScreen extends StatelessWidget {
  const RecruiterProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Recruiter? recruiter =
        context.watch<RecruiterProvider>().recruiter;
    if (recruiter == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up your company'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            color: scheme.primaryContainer,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Text(
              'Tell students about your company. You can post internships once '
              'this is done.',
              style: TextStyle(color: scheme.onPrimaryContainer),
            ),
          ),
          Expanded(
            child: RecruiterProfileEditor(
              initial: recruiter,
              submitLabel: 'Start posting',
              onSubmit: (Recruiter updated) async {
                await context.read<RecruiterProvider>().saveProfile(updated);
                return true;
              },
            ),
          ),
        ],
      ),
    );
  }
}
