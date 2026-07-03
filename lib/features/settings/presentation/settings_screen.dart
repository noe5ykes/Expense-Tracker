import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/adaptive.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../authentication/presentation/auth_controller.dart';
import 'settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider);
    final auth = ref.watch(authControllerProvider);

    String themeLabel(ThemeMode mode) => switch (mode) {
          ThemeMode.system => l10n.systemDefault,
          ThemeMode.light => l10n.light,
          ThemeMode.dark => l10n.dark,
        };
    final languageLabel = switch (settings.locale?.languageCode) {
      'hi' => l10n.hindi,
      'en' => l10n.english,
      _ => l10n.systemDefault,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // Profile
            AppCard(
              onTap: () => context.push('/profile'),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: scheme.primaryContainer,
                    child: Text(
                      auth.name.isNotEmpty ? auth.name[0].toUpperCase() : '?',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: scheme.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(auth.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16)),
                        Text(auth.email,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
            _SectionLabel(l10n.general),
            _SettingsGroup(children: [
              _NavTile(
                icon: Icons.language_rounded,
                title: l10n.language,
                value: languageLabel,
                onTap: () => _pickLanguage(context, ref),
              ),
              _NavTile(
                icon: Icons.dark_mode_outlined,
                title: l10n.theme,
                value: themeLabel(settings.themeMode),
                onTap: () => _pickTheme(context, ref),
              ),
              _NavTile(
                icon: Icons.currency_rupee_rounded,
                title: l10n.defaultCurrency,
                value: settings.currencyCode,
                onTap: () => _pickCurrency(context, ref),
              ),
              _NavTile(
                icon: Icons.category_outlined,
                title: l10n.manageCategories,
                onTap: () => context.push('/categories'),
              ),
              _NavTile(
                icon: Icons.receipt_long_outlined,
                title: l10n.upcomingBills,
                onTap: () => context.push('/bills'),
              ),
              _NavTile(
                icon: Icons.description_outlined,
                title: l10n.reports,
                onTap: () => context.push('/reports'),
              ),
            ]),
            _SectionLabel(l10n.notificationsSetting),
            _SettingsGroup(children: [
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.notifications_active_outlined),
                title: Text(l10n.dailyReminder),
                subtitle: Text(l10n.dailyReminderDesc),
                value: settings.dailyReminder,
                onChanged: (enabled) =>
                    _toggleDailyReminder(context, ref, enabled),
              ),
              if (settings.dailyReminder)
                _NavTile(
                  icon: Icons.schedule_rounded,
                  title: l10n.dailyReminderTime,
                  value: settings.reminderTime.format(context),
                  onTap: () => _pickReminderTime(context, ref),
                ),
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.warning_amber_rounded),
                title: Text(l10n.budgetAlerts),
                subtitle: Text(l10n.budgetAlertsDesc),
                value: settings.budgetAlerts,
                onChanged: (enabled) {
                  ref.read(settingsProvider.notifier).setBudgetAlerts(enabled);
                  if (enabled) NotificationService.instance.requestPermissions();
                },
              ),
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.event_outlined),
                title: Text(l10n.billReminders),
                subtitle: Text(l10n.billRemindersDesc),
                value: settings.billReminders,
                onChanged: (enabled) {
                  ref.read(settingsProvider.notifier).setBillReminders(enabled);
                  if (enabled) NotificationService.instance.requestPermissions();
                },
              ),
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.summarize_outlined),
                title: Text(l10n.monthlySummary),
                subtitle: Text(l10n.monthlySummaryDesc),
                value: settings.monthlySummary,
                onChanged: (enabled) =>
                    _toggleMonthlySummary(context, ref, enabled),
              ),
            ]),
            _SectionLabel(l10n.dataSection),
            _SettingsGroup(children: [
              _NavTile(
                icon: Icons.cloud_upload_outlined,
                title: l10n.backup,
                value: l10n.backupDesc,
                onTap: () => _backup(context, ref),
              ),
              _NavTile(
                icon: Icons.cloud_download_outlined,
                title: l10n.restore,
                value: l10n.restoreDesc,
                onTap: () => _restore(context, ref),
              ),
            ]),
            _SectionLabel(l10n.security),
            _SettingsGroup(children: [
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.fingerprint_rounded),
                title: Text(l10n.appLock),
                subtitle: Text(l10n.appLockDesc),
                value: settings.appLock,
                onChanged: (enabled) => _toggleAppLock(context, ref, enabled),
              ),
            ]),
            _SectionLabel(l10n.about),
            _SettingsGroup(children: [
              _NavTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.privacy,
                onTap: () => _showInfoDialog(
                    context, l10n.privacy, l10n.privacyBody),
              ),
              _NavTile(
                icon: Icons.info_outline_rounded,
                title: l10n.about,
                onTap: () => _showInfoDialog(
                    context, l10n.about, '${l10n.aboutBody}\n\n${l10n.version} 1.0.0'),
              ),
              _NavTile(
                icon: Icons.chat_bubble_outline_rounded,
                title: l10n.feedback,
                onTap: () => _showFeedbackSheet(context),
              ),
            ]),
            _SectionLabel(l10n.dangerZone),
            _SettingsGroup(children: [
              _NavTile(
                icon: Icons.delete_forever_outlined,
                title: l10n.clearAllData,
                color: scheme.error,
                onTap: () => _clearAll(context, ref),
              ),
              _NavTile(
                icon: Icons.logout_rounded,
                title: l10n.logout,
                color: scheme.error,
                onTap: () => _logout(context, ref),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // --- pickers -------------------------------------------------------------

  void _pickLanguage(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.read(settingsProvider).locale;
    _showOptionsSheet<Locale?>(
      context,
      title: l10n.language,
      options: [
        (null, l10n.systemDefault),
        (const Locale('en'), l10n.english),
        (const Locale('hi'), l10n.hindi),
      ],
      selected: current,
      onSelected: (locale) =>
          ref.read(settingsProvider.notifier).setLocale(locale),
    );
  }

  void _pickTheme(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    _showOptionsSheet<ThemeMode>(
      context,
      title: l10n.theme,
      options: [
        (ThemeMode.system, l10n.systemDefault),
        (ThemeMode.light, l10n.light),
        (ThemeMode.dark, l10n.dark),
      ],
      selected: ref.read(settingsProvider).themeMode,
      onSelected: (mode) =>
          ref.read(settingsProvider.notifier).setThemeMode(mode),
    );
  }

  void _pickCurrency(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    _showOptionsSheet<String>(
      context,
      title: l10n.defaultCurrency,
      options: [
        for (final currency in AppConstants.currencies)
          (currency.code, '${currency.symbol}  ${currency.name}'),
      ],
      selected: ref.read(settingsProvider).currencyCode,
      onSelected: (code) =>
          ref.read(settingsProvider.notifier).setCurrency(code),
    );
  }

  void _showOptionsSheet<T>(
    BuildContext context, {
    required String title,
    required List<(T, String)> options,
    required T selected,
    required ValueChanged<T> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Text(title,
                style: Theme.of(ctx)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
          ),
          RadioGroup<T>(
            groupValue: selected,
            onChanged: (value) {
              selectionHaptic();
              onSelected(value as T);
              Navigator.of(ctx).pop();
            },
            child: Column(
              children: [
                for (final (value, label) in options)
                  RadioListTile<T>(value: value, title: Text(label)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- notification toggles ------------------------------------------------

  Future<void> _toggleDailyReminder(
      BuildContext context, WidgetRef ref, bool enabled) async {
    final l10n = context.l10n;
    ref.read(settingsProvider.notifier).setDailyReminder(enabled);
    if (enabled) {
      await NotificationService.instance.requestPermissions();
      final time = ref.read(settingsProvider).reminderTime;
      await NotificationService.instance.scheduleDailyReminder(
        hour: time.hour,
        minute: time.minute,
        title: l10n.dailyReminderNotifTitle,
        body: l10n.dailyReminderNotifBody,
      );
    } else {
      await NotificationService.instance.cancelDailyReminder();
    }
  }

  Future<void> _pickReminderTime(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final picked = await showAdaptiveTimePicker(context,
        initialTime: ref.read(settingsProvider).reminderTime);
    if (picked == null) return;
    ref.read(settingsProvider.notifier).setReminderTime(picked);
    await NotificationService.instance.scheduleDailyReminder(
      hour: picked.hour,
      minute: picked.minute,
      title: l10n.dailyReminderNotifTitle,
      body: l10n.dailyReminderNotifBody,
    );
  }

  Future<void> _toggleMonthlySummary(
      BuildContext context, WidgetRef ref, bool enabled) async {
    final l10n = context.l10n;
    ref.read(settingsProvider.notifier).setMonthlySummary(enabled);
    if (enabled) {
      await NotificationService.instance.requestPermissions();
      await NotificationService.instance.scheduleMonthlySummary(
        title: l10n.monthlySummaryNotifTitle,
        body: l10n.monthlySummaryNotifBody,
      );
    } else {
      await NotificationService.instance.cancelMonthlySummary();
    }
  }

  // --- data ----------------------------------------------------------------

  BackupService _backupService(WidgetRef ref) => BackupService(
        expenses: ref.read(expenseRepositoryProvider),
        categories: ref.read(categoryRepositoryProvider),
        budgets: ref.read(budgetRepositoryProvider),
        bills: ref.read(billRepositoryProvider),
      );

  Future<void> _backup(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    try {
      await _backupService(ref).exportAndShare();
      if (context.mounted) showAppSnackBar(context, l10n.backupCreated);
    } catch (_) {
      if (context.mounted) showAppSnackBar(context, l10n.somethingWentWrong);
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    try {
      final restored = await _backupService(ref).pickAndRestore();
      if (restored && context.mounted) {
        showAppSnackBar(context, l10n.restoreDone);
      }
    } catch (_) {
      if (context.mounted) showAppSnackBar(context, l10n.restoreFailed);
    }
  }

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.clearAllData,
      message: l10n.clearAllDataConfirm,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(expenseRepositoryProvider).clearAll();
    await ref.read(budgetRepositoryProvider).clearAll();
    await ref.read(billRepositoryProvider).clearAll();
    if (context.mounted) showAppSnackBar(context, l10n.dataCleared);
  }

  // --- security / session ----------------------------------------------------

  Future<void> _toggleAppLock(
      BuildContext context, WidgetRef ref, bool enabled) async {
    final l10n = context.l10n;
    if (!enabled) {
      ref.read(settingsProvider.notifier).setAppLock(false);
      return;
    }
    final service = BiometricService();
    if (!await service.isAvailable()) {
      if (context.mounted) {
        showAppSnackBar(context, l10n.biometricNotAvailable);
      }
      return;
    }
    if (!context.mounted) return;
    final ok = await service.authenticate(l10n.biometricPrompt);
    if (ok) {
      ref.read(settingsProvider.notifier).setAppLock(true);
    } else if (context.mounted) {
      showAppSnackBar(context, l10n.biometricFailed);
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.logout,
      message: l10n.logoutConfirm,
      confirmLabel: l10n.logout,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) context.go('/login');
  }

  // --- dialogs ---------------------------------------------------------------

  void _showInfoDialog(BuildContext context, String title, String body) {
    showAdaptiveDialog(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(title),
        content: SingleChildScrollView(child: Text(body)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(ctx.l10n.close),
          ),
        ],
      ),
    );
  }

  void _showFeedbackSheet(BuildContext context) {
    final l10n = context.l10n;
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 4, 24, 24 + MediaQuery.viewInsetsOf(ctx).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.sendFeedback,
                style: Theme.of(ctx)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(hintText: l10n.feedbackHint),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                showAppSnackBar(context, l10n.feedbackThanks);
              },
              child: Text(l10n.sendFeedback),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 26, 6, 10),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(children: children),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final Color? color;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.title,
    this.value,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title,
          style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      subtitle: value == null
          ? null
          : Text(value!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: scheme.onSurfaceVariant)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
