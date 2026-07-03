import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/utils/adaptive.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/utils/display.dart';
import '../../../shared/widgets/category_avatar.dart';
import '../../../shared/widgets/shimmer.dart';
import '../domain/category.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageCategories)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'categories-fab',
        onPressed: () => _showForm(context, ref, null),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addCategory),
      ),
      body: SafeArea(
        child: categoriesAsync.when(
          loading: () => const ListShimmer(),
          error: (e, _) => Center(child: Text(l10n.somethingWentWrong)),
          data: (categories) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final category = categories[index];
              final deletable = !category.isDefault;
              return Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: CategoryAvatar(category: category),
                  title: Text(categoryName(context, category),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle:
                      category.isIncome ? Text(l10n.income) : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: l10n.edit,
                        onPressed: () => _showForm(context, ref, category),
                      ),
                      if (deletable)
                        IconButton(
                          icon: Icon(Icons.delete_outline_rounded,
                              size: 20, color: scheme.error),
                          tooltip: l10n.delete,
                          onPressed: () => _delete(context, ref, category),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, Category category) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteCategory,
      message: l10n.deleteCategoryConfirm,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(categoryRepositoryProvider).delete(category.id);
    if (context.mounted) showAppSnackBar(context, l10n.categoryDeleted);
  }

  void _showForm(BuildContext context, WidgetRef ref, Category? category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CategoryFormSheet(category: category),
    );
  }
}

class _CategoryFormSheet extends ConsumerStatefulWidget {
  final Category? category;
  const _CategoryFormSheet({this.category});

  @override
  ConsumerState<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<_CategoryFormSheet> {
  late final TextEditingController _nameController;
  late String _icon;
  late int _color;
  late bool _isIncome;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _nameController = TextEditingController(text: c?.name ?? '');
    _icon = c?.icon ?? 'other';
    _color = c?.color ?? categoryPalette.first.toARGB32();
    _isIncome = c?.isIncome ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    final existing = widget.category;
    // Default categories keep their localization key; the custom name only
    // applies to user categories.
    if (existing == null || !existing.isDefault) {
      if (name.isEmpty) {
        showAppSnackBar(context, l10n.categoryNameRequired);
        return;
      }
    }
    final repo = ref.read(categoryRepositoryProvider);
    if (existing == null) {
      await repo.add(Category(
        id: const Uuid().v4(),
        name: name,
        icon: _icon,
        color: _color,
        isIncome: _isIncome,
      ));
    } else {
      await repo.update(existing.copyWith(
        name: existing.isDefault && name.isEmpty ? existing.name : name,
        icon: _icon,
        color: _color,
      ));
    }
    if (!mounted) return;
    successHaptic();
    showAppSnackBar(context, l10n.categorySaved);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final isEdit = widget.category != null;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: EdgeInsets.fromLTRB(
            24, 4, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
        children: [
          Text(isEdit ? l10n.editCategory : l10n.addCategory,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.categoryName,
              prefixIcon: const Icon(Icons.label_outline_rounded),
            ),
          ),
          if (!isEdit) ...[
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l10n.expense)),
                ButtonSegment(value: true, label: Text(l10n.income)),
              ],
              selected: {_isIncome},
              onSelectionChanged: (s) => setState(() => _isIncome = s.first),
            ),
          ],
          const SizedBox(height: 22),
          Text(l10n.pickIcon,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final entry in categoryIcons.entries)
                GestureDetector(
                  onTap: () {
                    selectionHaptic();
                    setState(() => _icon = entry.key);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _icon == entry.key
                          ? Color(_color).withValues(alpha: .18)
                          : scheme.surfaceContainerHighest
                              .withValues(alpha: .5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _icon == entry.key
                            ? Color(_color)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(entry.value,
                        color: _icon == entry.key
                            ? Color(_color)
                            : scheme.onSurfaceVariant),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Text(l10n.pickColor,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final color in categoryPalette)
                GestureDetector(
                  onTap: () {
                    selectionHaptic();
                    setState(() => _color = color.toARGB32());
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _color == color.toARGB32()
                            ? scheme.onSurface
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: _color == color.toARGB32()
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 22)
                        : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          FilledButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
    );
  }
}
