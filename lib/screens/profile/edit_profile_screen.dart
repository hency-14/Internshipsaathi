import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/student.dart';
import '../../providers/session_provider.dart';
import '../../widgets/profile_editor.dart';

/// Edit an existing profile. Saving re-runs the matching engine (handled in
/// [SessionProvider.saveProfile]) so the Matches tab reflects changes at once.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Student? student = context.watch<SessionProvider>().student;
    if (student == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: ProfileEditor(
        initial: student,
        submitLabel: 'Save changes',
        onSubmit: (Student updated) async {
          await context.read<SessionProvider>().saveProfile(updated);
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
