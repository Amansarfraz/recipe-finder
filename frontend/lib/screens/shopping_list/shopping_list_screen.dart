import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/shopping_list_service.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});
  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final ShoppingListService _service = ShoppingListService();
  final addItemCtrl = TextEditingController();

  List<dynamic> items = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
      ),
    );
  }

  Future<void> _load() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final result = await _service.getItems();
      setState(() => items = result);
    } catch (e) {
      setState(() => error = 'Could not load shopping list: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addItem() async {
    final name = addItemCtrl.text.trim();
    if (name.isEmpty) return;
    addItemCtrl.clear();
    try {
      final updated = await _service.addItem(name);
      setState(() => items = updated);
    } catch (e) {
      _showSnack('Could not add item: $e', isError: true);
    }
  }

  Future<void> _removeItem(String name) async {
    final backup = List<dynamic>.from(items);
    setState(() => items.removeWhere((i) => i['name'] == name));
    try {
      await _service.removeItem(name);
    } catch (e) {
      setState(() => items = backup);
      _showSnack('Could not remove item: $e', isError: true);
    }
  }

  Future<void> _toggleItem(String name, bool current) async {
    final backup = List<dynamic>.from(items);
    setState(() {
      final item = items.firstWhere((i) => i['name'] == name);
      item['have'] = !current;
    });
    try {
      await _service.toggleItem(name);
    } catch (e) {
      setState(() => items = backup);
      _showSnack('Could not update item: $e', isError: true);
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Shopping List'),
        content: const Text('This will remove all items. Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final backup = List<dynamic>.from(items);
    setState(() => items = []);
    try {
      await _service.clearList();
    } catch (e) {
      setState(() => items = backup);
      _showSnack('Could not clear list: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final needed = items.where((i) => !(i['have'] as bool)).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
                icon: const Icon(Icons.delete_outline), onPressed: _clearAll),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textGrey)),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12)),
                              child: TextField(
                                controller: addItemCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'Add an item...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                ),
                                onSubmitted: (_) => _addItem(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12)),
                            child: IconButton(
                                icon:
                                    const Icon(Icons.add, color: Colors.white),
                                onPressed: _addItem),
                          ),
                        ],
                      ),
                    ),
                    if (items.isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(14)),
                        child: Text('$needed items still needed',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark)),
                      ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: items.isEmpty
                          ? const Center(
                              child: Text('Your shopping list is empty',
                                  style: TextStyle(color: AppColors.textGrey)))
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: items.length,
                                itemBuilder: (context, i) {
                                  final item = items[i];
                                  final name = item['name'] as String;
                                  final have = item['have'] as bool;
                                  return Dismissible(
                                    key: ValueKey(name),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (_) => _removeItem(name),
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                          color: AppColors.danger,
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: const Icon(Icons.delete,
                                          color: Colors.white),
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: CheckboxListTile(
                                        contentPadding: EdgeInsets.zero,
                                        activeColor: AppColors.primary,
                                        value: have,
                                        title: Text(
                                          name,
                                          style: TextStyle(
                                            decoration: have
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: have
                                                ? AppColors.textGrey
                                                : AppColors.textDark,
                                          ),
                                        ),
                                        onChanged: (_) =>
                                            _toggleItem(name, have),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}
