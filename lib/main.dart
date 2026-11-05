import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/recruiter_provider.dart';
import 'providers/session_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/auth_gate.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only initialize Firebase when it's actually enabled, so the demo build
  // runs with no configuration at all. (DefaultFirebaseOptions.currentPlatform
  // is the generated config; the placeholder throws until you run
  // `flutterfire configure` — see README.)
  if (AppConfig.useFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const InternshipSaathiApp());
}

class InternshipSaathiApp extends StatelessWidget {
  const InternshipSaathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        // Student session data. The proxy re-runs whenever AuthProvider
        // notifies, forwarding the current user and role. It loads only for
        // student accounts.
        ChangeNotifierProxyProvider<AuthProvider, SessionProvider>(
          create: (_) => SessionProvider(),
          update: (_, AuthProvider auth, SessionProvider? session) {
            final SessionProvider s = session ?? SessionProvider();
            s.onUserChanged(auth.user, auth.role);
            return s;
          },
        ),
        // Recruiter data, loaded only for recruiter accounts.
        ChangeNotifierProxyProvider<AuthProvider, RecruiterProvider>(
          create: (_) => RecruiterProvider(),
          update: (_, AuthProvider auth, RecruiterProvider? recruiter) {
            final RecruiterProvider r = recruiter ?? RecruiterProvider();
            r.onUserChanged(auth.user, auth.role);
            return r;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, ThemeProvider theme, _) => MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.mode,
          home: const AuthGate(),
        ),
      ),
    );
  }
}
