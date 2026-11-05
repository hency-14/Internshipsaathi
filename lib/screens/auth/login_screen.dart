import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/ui_kit.dart';
import 'register_screen.dart';

/// Email/password sign-in. Also surfaces the demo account so the app can be
/// explored in one tap when running in local mode.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final AuthProvider auth = context.read<AuthProvider>();
    final bool ok = await auth.signIn(_email.text, _password.text);
    if (!ok && mounted) {
      _showError(auth.error ?? 'Sign in failed.');
    }
  }

  void _fillDemo() {
    _email.text = 'demo@saathi.app';
    _password.text = '123456';
  }

  Future<void> _forgotPassword() async {
    final String? email = await showDialog<String>(
      context: context,
      builder: (_) => _ResetPasswordDialog(initialEmail: _email.text.trim()),
    );
    if (email == null || email.isEmpty || !mounted) return;

    final AuthProvider auth = context.read<AuthProvider>();
    final bool ok = await auth.resetPassword(email);
    if (!mounted) return;
    _showError(ok
        ? 'Password reset link sent to $email.'
        : (auth.error ?? 'Could not send reset link.'));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _Hero(),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              'Welcome back',
                              style: text.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sign in to continue your search',
                              style: text.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 22),
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _password,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (String? v) =>
                                  (v == null || v.isEmpty)
                                      ? 'Enter your password'
                                      : null,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed:
                                    auth.busy ? null : _forgotPassword,
                                child: const Text('Forgot password?'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            GradientButton(
                              label: 'Sign in',
                              icon: Icons.login,
                              busy: auth.busy,
                              onPressed: auth.busy ? null : _submit,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("New here?",
                                    style: text.bodyMedium?.copyWith(
                                        color: scheme.onSurfaceVariant)),
                                TextButton(
                                  onPressed: auth.busy
                                      ? null
                                      : () => Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) =>
                                                  const RegisterScreen(),
                                            ),
                                          ),
                                  child: const Text('Create an account'),
                                ),
                              ],
                            ),
                            if (!AppConfig.useFirebase) ...<Widget>[
                              const Divider(height: 28),
                              Text(
                                'Demo mode — no backend required',
                                textAlign: TextAlign.center,
                                style: text.labelMedium
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed: auth.busy ? null : _fillDemo,
                                icon: const Icon(Icons.bolt_outlined),
                                label: const Text('Fill demo credentials'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter your email';
    if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
    return null;
  }
}

/// The brand gradient hero at the top of the sign-in screen: app monogram,
/// name and tagline on white.
class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return HeroGradientBox(
      radius: 32,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 56),
          child: Column(
            children: <Widget>[
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35), width: 1.5),
                ),
                child: const Icon(Icons.handshake_outlined,
                    size: 40, color: Colors.white),
              ),
              const SizedBox(height: 18),
              Text(
                AppConfig.appName,
                textAlign: TextAlign.center,
                style: text.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppConfig.tagline,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Password-reset dialog. It owns its own [TextEditingController] and disposes
/// it in [dispose] — which runs only after the dialog has fully left the tree —
/// so the controller is never torn down while its field is still mounted.
class _ResetPasswordDialog extends StatefulWidget {
  final String initialEmail;
  const _ResetPasswordDialog({required this.initialEmail});

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  late final TextEditingController _email =
      TextEditingController(text: widget.initialEmail);

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text("Enter your account email and we'll send a reset link."),
          const SizedBox(height: 16),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            onSubmitted: (_) => Navigator.of(context).pop(_email.text.trim()),
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_email.text.trim()),
          child: const Text('Send link'),
        ),
      ],
    );
  }
}
