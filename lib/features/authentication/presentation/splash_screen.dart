import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/app_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import 'auth_controller.dart';

const kOnboardingDoneKey = 'onboarding.done';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  bool _lockFailed = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    // Run session restore and the minimum splash duration in parallel.
    await Future.wait([
      ref.read(authControllerProvider.notifier).restoreSession(),
      Future<void>.delayed(const Duration(milliseconds: 1500)),
    ]);
    if (!mounted) return;
    await _route();
  }

  Future<void> _route() async {
    final prefs = ref.read(sharedPrefsProvider);
    if (!(prefs.getBool(kOnboardingDoneKey) ?? false)) {
      context.go('/onboarding');
      return;
    }
    final auth = ref.read(authControllerProvider);
    if (auth.status != AuthStatus.loggedIn) {
      context.go('/login');
      return;
    }
    if (ref.read(settingsProvider).appLock) {
      final ok = await BiometricService()
          .authenticate(context.mounted ? context.l10n.biometricPrompt : '');
      if (!mounted) return;
      if (!ok) {
        setState(() => _lockFailed = true);
        return;
      }
    }
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.seed,
              AppTheme.seed.withValues(alpha: .75),
              const Color(0xFF065F46),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: CurvedAnimation(
                    parent: _controller, curve: Curves.elasticOut),
                child: Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(32),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: .25)),
                  ),
                  child: const Icon(Icons.savings_rounded,
                      size: 64, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(.3, 1, curve: Curves.easeOut)),
                child: Column(
                  children: [
                    Text(
                      context.l10n.appName,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.appTagline,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: .85)),
                    ),
                  ],
                ),
              ),
              if (_lockFailed) ...[
                const SizedBox(height: 40),
                Text(context.l10n.biometricFailed,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: .9))),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () {
                    setState(() => _lockFailed = false);
                    _route();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: scheme.primary,
                    minimumSize: const Size(160, 48),
                  ),
                  child: Text(context.l10n.retry),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
