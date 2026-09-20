import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class BottomActionBar extends StatelessWidget {
  final VoidCallback onCategoryTap;
  final Function(TransactionType) onAddTransactionTap;

  const BottomActionBar({
    super.key,
    required this.onCategoryTap,
    required this.onAddTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Category Manager Button
            IconButton(
              icon: const Icon(
                Icons.category_outlined,
                size: 28,
                color: Colors.black87,
              ),
              onPressed: onCategoryTap,
            ),
            const Spacer(),

            // Expense Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.shade100,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.arrow_downward, color: Colors.red, size: 18),
              label: const Text('Expense', style: TextStyle(color: Colors.red)),
              onPressed: () => onAddTransactionTap(TransactionType.expense),
            ),
            const SizedBox(width: 10),

            // Income Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade100,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.arrow_upward, color: Colors.green, size: 18),
              label: const Text('Income', style: TextStyle(color: Colors.green)),
              onPressed: () => onAddTransactionTap(TransactionType.income),
            ),
          ],
        ),
      ),
    );
  }
}