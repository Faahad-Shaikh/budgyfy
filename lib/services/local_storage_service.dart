import 'package:shared_preferences/shared_preferences.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class LocalStorageService {
  static const String _accountsKey = 'user_accounts';
  static const String _categoriesKey = 'user_categories';
  static const String _transactionsKey = 'user_transactions';

  // --- Transactions ---
  static Future<List<TransactionModel>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedList = prefs.getStringList(_transactionsKey);

    if (savedList != null && savedList.isNotEmpty) {
      return savedList.map((json) => TransactionModel.fromJson(json)).toList();
    }
    return []; // Default empty list on first launch
  }

  static Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = transactions.map((tx) => tx.toJson()).toList();
    await prefs.setStringList(_transactionsKey, jsonList);
  }

  // --- Accounts ---
  static Future<List<AccountModel>> loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedList = prefs.getStringList(_accountsKey);

    if (savedList != null && savedList.isNotEmpty) {
      return savedList.map((json) => AccountModel.fromJson(json)).toList();
    }

    // First-time launch default seeding
    final defaults = AccountModel.getDummyAccounts();
    await saveAccounts(defaults);
    return defaults;
  }

  static Future<void> saveAccounts(List<AccountModel> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = accounts.map((acc) => acc.toJson()).toList();
    await prefs.setStringList(_accountsKey, jsonList);
  }

  // --- Categories ---
  static Future<List<CategoryModel>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedList = prefs.getStringList(_categoriesKey);

    if (savedList != null && savedList.isNotEmpty) {
      return savedList.map((json) => CategoryModel.fromJson(json)).toList();
    }

    final defaults = CategoryModel.getDummyCategories();
    await saveCategories(defaults);
    return defaults;
  }

  static Future<void> saveCategories(List<CategoryModel> categories) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = categories.map((cat) => cat.toJson()).toList();
    await prefs.setStringList(_categoriesKey, jsonList);
  }
}