import 'dart:convert';

class CategoryModel {
  final String id;
  final String name;
  final String iconName;
  final int colorValue;
  double totalSpent;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorValue,
    this.totalSpent = 0.0,
  });

  // 1. Convert instance to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'colorValue': colorValue,
      'totalSpent': totalSpent,
    };
  }

  // 2. Construct instance from Map
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      iconName: map['iconName'] ?? 'category',
      colorValue: map['colorValue'] ?? 0xFF9E9E9E,
      totalSpent: (map['totalSpent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // 3. Helper methods for String JSON encoding/decoding
  String toJson() => jsonEncode(toMap());

  factory CategoryModel.fromJson(String source) =>
      CategoryModel.fromMap(jsonDecode(source));

  // Default seed categories for first-time launch
  static List<CategoryModel> getDummyCategories() {
    return [

      // --- Income Categories ---
      CategoryModel(
        id: 'cat_salary',
        name: 'Salary',
        iconName: 'receipt',
        colorValue: 0xFF4CAF50, // Green
      ),
      CategoryModel(
        id: 'cat_allowance',
        name: 'Allowance',
        iconName: 'card_giftcard',
        colorValue: 0xFF00BCD4, // Cyan
      ),
      CategoryModel(
        id: 'cat_investments',
        name: 'Investments & Interest',
        iconName: 'home',
        colorValue: 0xFF3F51B5, // Indigo
      ),

      // --- Expense Categories---
      CategoryModel(
        id: 'cat_food',
        name: 'Food & Dining',
        iconName: 'fastfood',
        colorValue: 0xFFFF5722, // Deep Orange
      ),
      CategoryModel(
        id: 'cat_groceries',
        name: 'Groceries',
        iconName: 'shopping_cart',
        colorValue: 0xFF4CAF50, // Green
      ),
      CategoryModel(
        id: 'cat_transit',
        name: 'Transit & Fuel',
        iconName: 'directions_car',
        colorValue: 0xFF2196F3, // Blue
      ),
      CategoryModel(
        id: 'cat_shopping',
        name: 'Shopping & Gifts',
        iconName: 'card_giftcard',
        colorValue: 0xFF9C27B0, // Purple
      ),
      CategoryModel(
        id: 'cat_bills',
        name: 'Bills & Utilities',
        iconName: 'receipt',
        colorValue: 0xFFFFC107, // Amber
      ),
    ];
  }
}