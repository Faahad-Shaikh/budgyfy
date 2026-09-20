import 'package:flutter/material.dart';
import '../models/category_model.dart';
import 'delete_dialog.dart';

class CategoryModal extends StatefulWidget {
  final List<CategoryModel> categories;
  final Function(CategoryModel) onCategoryCreated;
  final Function(String) onCategoryDeleted;

  const CategoryModal({
    super.key,
    required this.categories,
    required this.onCategoryCreated,
    required this.onCategoryDeleted,
  });

  @override
  State<CategoryModal> createState() => _CategoryModalState();
}

class _CategoryModalState extends State<CategoryModal> {
  final TextEditingController _categoryNameController = TextEditingController();
  int _selectedColor = 0xFF4CAF50;
  String _selectedIcon = 'fastfood';

  final List<int> _colorPalette = [
    0xFFFF5722,
    0xFF4CAF50,
    0xFF2196F3,
    0xFF9C27B0,
    0xFFFFC107,
    0xFFE91E63,
    0xFF607D8B,
  ];

  final Map<String, IconData> _iconPalette = {
    'fastfood': Icons.fastfood,
    'shopping_cart': Icons.shopping_cart,
    'directions_car': Icons.directions_car,
    'card_giftcard': Icons.card_giftcard,
    'receipt': Icons.receipt,
    'attach_money': Icons.attach_money,
    'payments': Icons.payments,
    'account_balance': Icons.account_balance,
    'home': Icons.home,
    'fitness_center': Icons.fitness_center,
    'movie': Icons.movie,
  };

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  void _submitCategory() {
    final name = _categoryNameController.text.trim();
    if (name.isEmpty) return;

    final newCategory = CategoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      iconName: _selectedIcon,
      colorValue: _selectedColor,
    );

    widget.onCategoryCreated(newCategory);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Manage Categories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _categoryNameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              hintText: 'e.g. Health, Entertainment',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          const Text('Select Icon', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _iconPalette.entries.map((entry) {
                final isSelected = _selectedIcon == entry.key;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = entry.key),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(_selectedColor).withValues(alpha: 0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? Color(_selectedColor) : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(entry.value,
                        color: isSelected ? Color(_selectedColor) : Colors.grey),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 15),
          const Text('Select Accent Color', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _colorPalette.map((colorHex) {
                final isSelected = _selectedColor == colorHex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = colorHex),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(colorHex),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitCategory,
            child: const Text('Add Category'),
          ),
          const Divider(height: 30),
          const Text('Existing Categories', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: ListView.builder(
              itemCount: widget.categories.length,
              itemBuilder: (context, index) {
                final cat = widget.categories[index];
                final iconData = _iconPalette[cat.iconName] ?? Icons.category;

                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: Color(cat.colorValue).withValues(alpha: 0.2),
                    child: Icon(iconData, color: Color(cat.colorValue), size: 18),
                  ),
                  title: Text(cat.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () async {
                      final confirmed = await showDeleteConfirmationDialog(
                        context: context,
                        title: 'Delete Category?',
                        content: 'Are you sure you want to permanently delete this category?',
                      );
                      if (confirmed) {
                        widget.onCategoryDeleted(cat.id);
                        setState(() {});
                      }
                    },
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