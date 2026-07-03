import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../features/expenses/domain/category.dart';

class CategoryAvatar extends StatelessWidget {
  final Category? category;
  final double size;

  const CategoryAvatar({super.key, required this.category, this.size = 46});

  @override
  Widget build(BuildContext context) {
    final color = Color(category?.color ?? 0xFF8B5CF6);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(size * 0.34),
      ),
      child: Icon(
        iconForKey(category?.icon ?? 'other'),
        color: color,
        size: size * 0.5,
      ),
    );
  }
}
