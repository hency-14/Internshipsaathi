import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/recruiter.dart';
import '../../providers/recruiter_provider.dart';
import '../../widgets/recruiter_profile_editor.dart';

/// Edit the recruiter's company profile.
class RecruiterEditProfileScreen extends StatelessWidget {
  const RecruiterEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Recruiter? recruiter =
        context.watch<RecruiterProvider>().recruiter;
    if (recruiter == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit company profile')),
      body: RecruiterProfileEditor(
        initial: recruiter,
        submitLabel: 'Save changes',
        onSubmit: (Recruiter updated) async {
          await context.read<RecruiterProvider>().saveProfile(updated);
          if (context.mounted) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                  const SnackBar(content: Text('Profile updated.')));
            Navigator.of(context).pop();
          }
          return true;
        },
      ),
    );
  }
}
