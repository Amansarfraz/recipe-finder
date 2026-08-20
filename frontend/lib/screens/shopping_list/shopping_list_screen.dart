import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});
  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  // Placeholder — replace with GET /shopping-list results
  final List<Map<String, dynamic>> items = [
    {'name': 'Chicken', 'have': true},
    {'name': 'Tomato', 'have': false},
    {'name': 'Onions', 'have': true},
    {'name': 'Cooking Oil', 'have': false},
    {'name': 'Curry Powder', 'have': false},
  ];

  @override
  Widget build(BuildContext context) {
    final needed = items.where((i) => !i['have']).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() => items.clear()))],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.4), borderRadius: BorderRadius.circular(14)),
            child: Text('$needed items still needed', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Your shopping list is empty', style: TextStyle(color: AppColors.textGrey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                          value: item['have'],
                          title: Text(
                            item['name'],
                            style: TextStyle(
                              decoration: item['have'] ? TextDecoration.lineThrough : null,
                              color: item['have'] ? AppColors.textGrey : AppColors.textDark,
                            ),
                          ),
                          onChanged: (v) => setState(() => item['have'] = v),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
