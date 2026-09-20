import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import 'delete_dialog.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final List<AccountModel> accounts;
  final List<CategoryModel> categories;
  final AccountModel? selectedAccount;
  final Function(String) onDeleteTransaction;
  final Function(TransactionModel) onEditTransaction;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.accounts,
    required this.categories,
    required this.selectedAccount,
    required this.onDeleteTransaction,
    required this.onEditTransaction,
  });

  List<TransactionModel> get filteredTransactions {
    if (selectedAccount == null || selectedAccount!.id == 'all') {
      return transactions;
    }
    return transactions
        .where((tx) => tx.accountId == selectedAccount!.id)
        .toList();
  }

  static const Map<String, IconData> _iconPalette = {
    'receipt': Icons.receipt,
    'attach_money': Icons.attach_money,
    'payments': Icons.payments,
    'account_balance': Icons.account_balance,
    'fastfood': Icons.fastfood,
    'shopping_cart': Icons.shopping_cart,
    'directions_car': Icons.directions_car,
    'card_giftcard': Icons.card_giftcard,
    'home': Icons.home,
    'fitness_center': Icons.fitness_center,
    'movie': Icons.movie,
  };

  @override
  Widget build(BuildContext context) {
    final list = filteredTransactions.reversed.toList();

    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              'No transactions logged yet',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final tx = list[index];

              final category = categories.firstWhere(
                    (c) => c.id == tx.categoryId,
                orElse: () => CategoryModel(
                  id: '',
                  name: 'General',
                  iconName: 'receipt',
                  colorValue: 0xFF9E9E9E,
                ),
              );

              final account = accounts.firstWhere(
                    (a) => a.id == tx.accountId,
                orElse: () => AccountModel(id: '', name: 'Account', initialBalance: 0.0),
              );

              final iconData = _iconPalette[category.iconName] ?? Icons.category;
              final isExpense = tx.type == TransactionType.expense;

              return Dismissible(
                key: Key(tx.id),
                direction: DismissDirection.endToStart, // Swipe left
                confirmDismiss: (direction) async {
                  return await showDeleteConfirmationDialog(
                    context: context,
                    title: 'Delete Transaction?',
                    content: 'Are you sure you want to permanently delete this transaction entry?',
                  );
                },
                onDismissed: (direction) {
                  onDeleteTransaction(tx.id);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                ),
                child: Card(
                  elevation: 0,
                  color: const Color(0xFFF8F9FA),
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () => onEditTransaction(tx),
                    leading: CircleAvatar(
                      backgroundColor: Color(category.colorValue).withValues(alpha: 0.2),
                      child: Icon(iconData, color: Color(category.colorValue), size: 20),
                    ),
                    title: Text(
                      tx.title ?? category.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${account.name} • ${_formatDate(tx.date)}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    trailing: Text(
                      '${isExpense ? '-' : '+'}₹${tx.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isExpense ? Colors.redAccent : Colors.green,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}