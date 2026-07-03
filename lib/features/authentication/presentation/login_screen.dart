import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/utils/adaptive.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  bool _biometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    BiometricService().isAvailable().then((available) {
      if (mounted) setState(() => _biometricsAvailable = available);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final ok = await ref
        .read(authControllerProvider.notifier)
        .login(_emailController.text, _passwordController.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      successHaptic();
      context.go('/home');
    } else {
      showAppSnackBar(context, context.l10n.invalidCredentials);
    }
  }

  Future<void> _biometricLogin() async {
    final l10n = context.l10n;
    if (!ref.read(authControllerProvider).hasAccount) {
      showAppSnackBar(context, l10n.invalidCredentials);
      return;
    }
    final ok = await BiometricService().authenticate(l10n.biometricPrompt);
    if (!mounted) return;
    if (!ok) {
      showAppSnackBar(context, l10n.biometricFailed);
      return;
    }
    await ref.read(authControllerProvider.notifier).loginWithBiometrics();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.savings_rounded, size: 56, color: scheme.primary),
                    const SizedBox(height: 20),
                    Text(l10n.welcomeBack,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(l10n.loginSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 36),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: l10n.email,
                        prefixIcon: const Icon(Icons.mail_outline_rounded),
                      ),
                      validator: (v) => _validateEmail(context, v),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? l10n.passwordRequired
                          : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: Text(l10n.forgotPassword),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5))
                          : Text(l10n.signIn),
                    ),
                    if (_biometricsAvailable) ...[
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: _biometricLogin,
                        icon: const Icon(Icons.fingerprint_rounded),
                        label: Text(l10n.useBiometrics),
                      ),
                    ],
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.dontHaveAccount,
                            style: TextStyle(color: scheme.onSurfaceVariant)),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: Text(l10n.createAccount),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? _validateEmail(BuildContext context, String? value) {
  final l10n = context.l10n;
  if (value == null || value.trim().isEmpty) return l10n.emailRequired;
  final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!emailPattern.hasMatch(value.trim())) return l10n.invalidEmail;
  return null;
}
