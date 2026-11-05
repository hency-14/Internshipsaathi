import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recruiter_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/error_retry.dart';
import '../home/home_shell.dart';
import '../recruiter/recruiter_home_shell.dart';
import '../recruiter/recruiter_profile_setup_screen.dart';
import 'login_screen.dart';
import 'profile_setup_screen.dart';

/// Top-level router. Decides what to show from auth state and the user's role:
///   signed out                       -> Login
///   role not resolved yet            -> loading
///   student,  no profile             -> student profile setup
///   student,  ready                  -> student Home
///   recruiter, no company profile    -> recruiter profile setup
///   recruiter, ready                 -> recruiter Home
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();

    if (!auth.isSignedIn) {
      return const LoginScreen();
    }

    // Signed in but role not loaded yet.
    if (auth.role == null) {
      return const _Loading();
    }

    if (auth.role == UserRole.recruiter) {
      return const _RecruiterFlow();
    }
    return const _StudentFlow();
  }
}

class _StudentFlow extends StatelessWidget {
  const _StudentFlow();

  @override
  Widget build(BuildContext context) {
    final SessionProvider session = context.watch<SessionProvider>();
    if (session.student == null) {
      if (session.error != null) {
        return ErrorRetry(message: session.error!, onRetry: session.retry);
      }
      return const _Loading();
    }
    if (!session.profileComplete) return const ProfileSetupScreen();
    return const HomeShell();
  }
}

class _RecruiterFlow extends StatelessWidget {
  const _RecruiterFlow();

  @override
  Widget build(BuildContext context) {
    final RecruiterProvider recruiter = context.watch<RecruiterProvider>();
    if (recruiter.recruiter == null) {
      if (recruiter.error != null) {
        return ErrorRetry(message: recruiter.error!, onRetry: recruiter.retry);
      }
      return const _Loading();
    }
    if (!recruiter.profileComplete) return const RecruiterProfileSetupScreen();
    return const RecruiterHomeShell();
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
