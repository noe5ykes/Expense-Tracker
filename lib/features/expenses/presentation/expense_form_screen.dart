import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/adaptive.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/utils/display.dart';
import '../../../shared/widgets/category_avatar.dart';
import '../../settings/presentation/settings_providers.dart';
import '../domain/category.dart';
import '../domain/expense.dart';
import 'expense_providers.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  final ExpenseFormArgs args;
  const ExpenseFormScreen({super.key, required this.args});

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late final TextEditingController _tagsController;
  late final TextEditingController _locationController;

  Expense? get _editing => widget.args.expense;

  late TransactionType _type;
  String? _categoryId;
  late DateTime _date;
  late PaymentMethod _method;
  late String _currency;
  late List<String> _receipts;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final e = _editing;
    _titleController = TextEditingController(text: e?.title ?? '');
    _amountController = TextEditingController(
        text: e == null
            ? ''
            : (e.amount == e.amount.roundToDouble()
                ? e.amount.toStringAsFixed(0)
                : e.amount.toString()));
    _notesController = TextEditingController(text: e?.notes ?? '');
    _tagsController = TextEditingController(text: e?.tags.join(', ') ?? '');
    _locationController = TextEditingController(text: e?.location ?? '');
    _type = e?.type ?? TransactionType.expense;
    _categoryId = e?.categoryId ?? widget.args.presetCategoryId;
    _date = e?.date ?? DateTime.now();
    _method = e?.paymentMethod ?? PaymentMethod.upi;
    _currency = e?.currency ?? ref.read(settingsProvider).currencyCode;
    _receipts = [...?e?.receiptPaths];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt(ImageSource source) async {
    try {
      final picked = await ImagePicker()
          .pickImage(source: source, maxWidth: 1600, imageQuality: 85);
      if (picked == null) return;
      // Copy into app-private storage so receipts survive gallery cleanup.
      final dir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory(p.join(dir.path, 'receipts'));
      await receiptsDir.create(recursive: true);
      final fileName = '${const Uuid().v4()}${p.extension(picked.path)}';
      final saved = await File(picked.path)
          .copy(p.join(receiptsDir.path, fileName));
      setState(() => _receipts.add(saved.path));
    } catch (_) {
      if (mounted) showAppSnackBar(context, context.l10n.somethingWentWrong);
    }
  }

  void _showReceiptSourceSheet() {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: Text(l10n.cameraOption),
              onTap: () {
                Navigator.pop(ctx);
                _pickReceipt(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(l10n.galleryOption),
              onTap: () {
                Navigator.pop(ctx);
                _pickReceipt(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      showAppSnackBar(context, l10n.selectCategory);
      return;
    }
    setState(() => _busy = true);

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final expense = Expense(
      id: _editing?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.replaceAll(',', '.')),
      categoryId: _categoryId!,
      date: _date,
      type: _type,
      paymentMethod: _method,
      notes: _notesController.text.trim(),
      tags: tags,
      currency: _currency,
      receiptPaths: _receipts,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
    );

    final categories = ref.read(categoriesByIdProvider);
    String categoryLabel(String id) {
      final category = categories[id];
      return category == null ? id : categoryName(context, category);
    }

    // Capture localized labels before the async gap.
    final labels = {
      for (final id in categories.keys) id: categoryLabel(id),
    };

    await saveExpense(
      ref,
      expense,
      previous: _editing,
      l10n: l10n,
      categoryLabel: (id) => labels[id] ?? id,
    );

    if (!mounted) return;
    successHaptic();
    showAppSnackBar(context, l10n.expenseSaved);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final categories = (ref.watch(categoriesProvider).value ?? <Category>[])
        .where((c) => c.isIncome == (_type == TransactionType.income))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing == null ? l10n.addExpense : l10n.editExpense),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              SegmentedButton<TransactionType>(
                segments: [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text(l10n.expense),
                    icon: const Icon(Icons.arrow_upward_rounded),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text(l10n.income),
                    icon: const Icon(Icons.arrow_downward_rounded),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (selection) => setState(() {
                  _type = selection.first;
                  _categoryId = null;
                }),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.title,
                  prefixIcon: const Icon(Icons.edit_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.titleRequired
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.amount,
                        prefixText:
                            '${AppConstants.currencySymbol(_currency)} ',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return l10n.amountRequired;
                        }
                        final parsed =
                            double.tryParse(v.replaceAll(',', '.'));
                        if (parsed == null || parsed <= 0) {
                          return l10n.invalidAmount;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _currency,
                      decoration: InputDecoration(labelText: l10n.currency),
                      items: [
                        for (final currency in AppConstants.currencies)
                          DropdownMenuItem(
                            value: currency.code,
                            child: Text(
                                '${currency.symbol} ${currency.code}'),
                          ),
                      ],
                      onChanged: (v) =>
                          setState(() => _currency = v ?? _currency),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(l10n.category,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final selected = category.id == _categoryId;
                    return GestureDetector(
                      onTap: () {
                        selectionHaptic();
                        setState(() => _categoryId = category.id);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 74,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? Color(category.color).withValues(alpha: .14)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? Color(category.color)
                                : scheme.outlineVariant
                                    .withValues(alpha: .4),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CategoryAvatar(category: category, size: 42),
                            const SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4),
                              child: Text(
                                categoryName(context, category),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _PickerField(
                      icon: Icons.calendar_today_rounded,
                      label: l10n.date,
                      value: Formatters.date(_date,
                          locale:
                              Localizations.localeOf(context).toString()),
                      onTap: () async {
                        final picked = await showAdaptiveDatePicker(context,
                            initialDate: _date);
                        if (picked != null) {
                          setState(() => _date = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              _date.hour,
                              _date.minute));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PickerField(
                      icon: Icons.schedule_rounded,
                      label: l10n.time,
                      value: Formatters.time(_date,
                          locale:
                              Localizations.localeOf(context).toString()),
                      onTap: () async {
                        final picked = await showAdaptiveTimePicker(context,
                            initialTime: TimeOfDay.fromDateTime(_date));
                        if (picked != null) {
                          setState(() => _date = DateTime(
                              _date.year,
                              _date.month,
                              _date.day,
                              picked.hour,
                              picked.minute));
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(l10n.paymentMethod,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final method in PaymentMethod.values)
                    ChoiceChip(
                      label: Text(paymentMethodLabel(context, method)),
                      selected: _method == method,
                      onSelected: (_) => setState(() => _method = method),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: '${l10n.tags} (${l10n.optional})',
                  hintText: l10n.tagsHint,
                  prefixIcon: const Icon(Icons.tag_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: '${l10n.location} (${l10n.optional})',
                  hintText: l10n.locationHint,
                  prefixIcon: const Icon(Icons.place_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: '${l10n.notes} (${l10n.optional})',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 22),
              Text(l10n.receipts,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              SizedBox(
                height: 92,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _AddReceiptButton(onTap: _showReceiptSourceSheet),
                    for (final path in _receipts)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 12),
                        child: _ReceiptThumb(
                          path: path,
                          onRemove: () =>
                              setState(() => _receipts.remove(path)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              FilledButton(
                onPressed: _busy ? null : _save,
                child: _busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5))
                    : Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        child: Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _AddReceiptButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddReceiptButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 92,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_rounded, color: scheme.primary),
            const SizedBox(height: 6),
            Text(context.l10n.addReceipt,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ReceiptThumb extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;
  const _ReceiptThumb({required this.path, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(path),
            width: 92,
            height: 92,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 92,
              height: 92,
              color: scheme.surfaceContainerHighest,
              child: const Icon(Icons.broken_image_rounded),
            ),
          ),
        ),
        PositionedDirectional(
          top: 4,
          end: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .55),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.close_rounded, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
