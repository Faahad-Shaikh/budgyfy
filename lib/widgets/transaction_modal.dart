import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class TransactionModal extends StatefulWidget {
  final TransactionType initialType;
  final List<AccountModel> accounts;
  final List<CategoryModel> categories;
  final AccountModel? selectedAccount;
  final TransactionModel? existingTransaction; // Optional parameter for editing
  final Function(TransactionModel) onTransactionSaved;

  const TransactionModal({
    super.key,
    required this.initialType,
    required this.accounts,
    required this.categories,
    required this.selectedAccount,
    this.existingTransaction,
    required this.onTransactionSaved,
  });

  @override
  State<TransactionModal> createState() => _TransactionModalState();
}

class _TransactionModalState extends State<TransactionModal> {
  late TransactionType _type;
  late String _selectedAccountId;
  String? _selectedCategoryId;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final isEditing = widget.existingTransaction != null;

    if (isEditing) {
      final tx = widget.existingTransaction!;
      _type = tx.type;
      _selectedAccountId = tx.accountId;
      _selectedCategoryId = tx.categoryId;
      _amountController.text = tx.amount.toStringAsFixed(2);
      _titleController.text = tx.title ?? '';
    } else {
      _type = widget.initialType;

      final actualAccounts = widget.accounts.where((a) => a.id != 'all').toList();

      if (widget.selectedAccount != null && widget.selectedAccount!.id != 'all') {
        _selectedAccountId = widget.selectedAccount!.id;
      } else if (actualAccounts.isNotEmpty) {
        _selectedAccountId = actualAccounts.first.id;
      } else {
        _selectedAccountId = '';
      }

      if (widget.categories.isNotEmpty) {
        _selectedCategoryId = widget.categories.first.id;
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _submitTransaction() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty || _selectedAccountId.isEmpty || _selectedCategoryId == null) {
      return;
    }

    final double? parsedAmount = double.tryParse(amountText);
    if (parsedAmount == null || parsedAmount <= 0) return;

    final updatedOrNewTransaction = TransactionModel(
      id: widget.existingTransaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      accountId: _selectedAccountId,
      categoryId: _selectedCategoryId!,
      amount: parsedAmount,
      type: _type,
      title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      date: widget.existingTransaction?.date ?? DateTime.now(),
    );

    widget.onTransactionSaved(updatedOrNewTransaction);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final actualAccounts = widget.accounts.where((a) => a.id != 'all').toList();
    final isEditing = widget.existingTransaction != null;

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
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Expense')),
                  selected: _type == TransactionType.expense,
                  selectedColor: Colors.redAccent.shade100,
                  onSelected: (selected) {
                    if (selected) setState(() => _type = TransactionType.expense);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Income')),
                  selected: _type == TransactionType.income,
                  selectedColor: Colors.green.shade200,
                  onSelected: (selected) {
                    if (selected) setState(() => _type = TransactionType.income);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: !isEditing,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '₹ ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),

          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Note / Title (Optional)',
              hintText: 'e.g. Coffee, Salary, Dinner',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),

          DropdownButtonFormField<String>(
            initialValue: _selectedAccountId.isNotEmpty ? _selectedAccountId : null,
            decoration: const InputDecoration(
              labelText: 'Account',
              border: OutlineInputBorder(),
            ),
            items: actualAccounts.map((acc) {
              return DropdownMenuItem(
                value: acc.id,
                child: Text(acc.name),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedAccountId = val);
            },
          ),
          const SizedBox(height: 15),

          DropdownButtonFormField<String>(
            initialValue: _selectedCategoryId,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: widget.categories.map((cat) {
              return DropdownMenuItem(
                value: cat.id,
                child: Text(cat.name),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCategoryId = val);
            },
          ),
          const SizedBox(height: 25),

          ElevatedButton(
            onPressed: _submitTransaction,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: _type == TransactionType.expense
                  ? Colors.redAccent
                  : Colors.green,
            ),
            child: Text(
              isEditing
                  ? 'Update Transaction'
                  : (_type == TransactionType.expense ? 'Add Expense' : 'Add Income'),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}