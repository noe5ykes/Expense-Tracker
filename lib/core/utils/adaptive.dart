import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Platform-adaptive helpers: Cupertino pickers/dialogs on iOS, Material
/// elsewhere, plus haptic feedback shortcuts.
bool isCupertino(BuildContext context) {
  final platform = Theme.of(context).platform;
  return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
}

void lightHaptic() => HapticFeedback.lightImpact();
void selectionHaptic() => HapticFeedback.selectionClick();
void successHaptic() => HapticFeedback.mediumImpact();

Future<DateTime?> showAdaptiveDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final first = firstDate ?? DateTime(2015);
  final last = lastDate ?? DateTime.now().add(const Duration(days: 365 * 5));
  if (isCupertino(context)) {
    DateTime selected = initialDate;
    final confirmed = await _showCupertinoPickerSheet(
      context,
      CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        initialDateTime: initialDate,
        minimumDate: first,
        maximumDate: last,
        onDateTimeChanged: (d) => selected = d,
      ),
    );
    return confirmed ? selected : null;
  }
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: first,
    lastDate: last,
  );
}

Future<TimeOfDay?> showAdaptiveTimePicker(
  BuildContext context, {
  required TimeOfDay initialTime,
}) async {
  if (isCupertino(context)) {
    final now = DateTime.now();
    DateTime selected = DateTime(
        now.year, now.month, now.day, initialTime.hour, initialTime.minute);
    final confirmed = await _showCupertinoPickerSheet(
      context,
      CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        initialDateTime: selected,
        onDateTimeChanged: (d) => selected = d,
      ),
    );
    return confirmed ? TimeOfDay.fromDateTime(selected) : null;
  }
  return showTimePicker(context: context, initialTime: initialTime);
}

Future<bool> _showCupertinoPickerSheet(
    BuildContext context, Widget picker) async {
  final result = await showCupertinoModalPopup<bool>(
    context: context,
    builder: (ctx) => Container(
      height: 300,
      padding: const EdgeInsets.only(top: 6),
      margin: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      color: CupertinoColors.systemBackground.resolveFrom(ctx),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
                ),
              ],
            ),
            Expanded(child: picker),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

/// Adaptive confirmation dialog. Returns true when confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
}) async {
  final result = await showAdaptiveDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog.adaptive(
      title: Text(title),
      content: Text(message),
      actions: isCupertino(ctx)
          ? [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(cancelLabel),
              ),
              CupertinoDialogAction(
                isDestructiveAction: destructive,
                isDefaultAction: !destructive,
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(confirmLabel),
              ),
            ]
          : [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(cancelLabel),
              ),
              FilledButton(
                style: destructive
                    ? FilledButton.styleFrom(
                        backgroundColor: Theme.of(ctx).colorScheme.error,
                        minimumSize: const Size(0, 44),
                      )
                    : FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(confirmLabel),
              ),
            ],
    ),
  );
  return result ?? false;
}

void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));
}
