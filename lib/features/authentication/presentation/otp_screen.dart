import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/utils/adaptive.dart';

/// Placeholder OTP verification — accepts [AppConstants.demoOtp]. The screen
/// is wired so a real SMS/email OTP backend can be dropped in later.
class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _verify() {
    final l10n = context.l10n;
    if (_controller.text.trim() == AppConstants.demoOtp) {
      successHaptic();
      showAppSnackBar(context, l10n.passwordResetDone);
      context.go('/login');
    } else {
      showAppSnackBar(context, l10n.invalidOtp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.sms_outlined, size: 56, color: scheme.primary),
                  const SizedBox(height: 20),
                  Text(l10n.otpTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(l10n.otpSubtitle(widget.email),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        letterSpacing: 14, fontWeight: FontWeight.w800),
                    decoration: const InputDecoration(
                        counterText: '', hintText: '••••••'),
                    onSubmitted: (_) => _verify(),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(onPressed: _verify, child: Text(l10n.verify)),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => showAppSnackBar(context, l10n.codeSent),
                    child: Text(l10n.resendCode),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
