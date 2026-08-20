import 'package:flutter/material.dart';
import '../core/theme.dart';

class IngredientChip extends StatelessWidget {
  final String label;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const IngredientChip({super.key, required this.label, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textDark)),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primaryDark, size: 20),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.danger, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
