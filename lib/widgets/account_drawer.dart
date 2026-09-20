import 'package:flutter/material.dart';
import '../models/account_model.dart';
import 'delete_dialog.dart';

class AccountDrawer extends StatefulWidget {
  final List<AccountModel> accounts;
  final AccountModel? selectedAccount;
  final double totalBalance;
  final Function(AccountModel) onAccountSelected;
  final Function(AccountModel) onAccountCreated;
  final Function(String) onAccountDeleted;

  const AccountDrawer({
    super.key,
    required this.accounts,
    required this.totalBalance,
    required this.selectedAccount,
    required this.onAccountSelected,
    required this.onAccountCreated,
    required this.onAccountDeleted,
  });

  @override
  State<AccountDrawer> createState() => _AccountDrawerState();
}

class _AccountDrawerState extends State<AccountDrawer> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submitNewAccount() {
    final String name = _nameController.text.trim();
    final String balanceText = _balanceController.text.trim();

    if (name.isEmpty || balanceText.isEmpty) return;

    final double? parsedBalance = double.tryParse(balanceText);
    if (parsedBalance == null) return;

    final AccountModel newAccount = AccountModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      initialBalance: parsedBalance,
    );

    widget.onAccountCreated(newAccount);

    _nameController.clear();
    _balanceController.clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Create New Account',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Account Name',
                hintText: 'e.g. Bank, Cash, Savings',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Initial Balance',
                hintText: '0.00',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _submitNewAccount,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Create Account'),
            ),
            const Divider(height: 40),
            const Text(
              'Existing Accounts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.accounts.length,
                itemBuilder: (context, index) {
                  final account = widget.accounts[index];
                  final isAllAccounts = account.id == 'all';
                  final isSelected = widget.selectedAccount?.id == account.id;

                  return ListTile(
                    selected: isSelected,
                    title: Text(account.name),
                    subtitle: isAllAccounts
                        ? Text('Total: ₹${widget.totalBalance.toStringAsFixed(2)}')
                        : Text('Balance: ₹${account.balance.toStringAsFixed(2)}'),
                    onTap: () {
                      widget.onAccountSelected(account);
                      Navigator.of(context).pop();
                    },
                    trailing: isAllAccounts
                        ? null
                        : IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () async {
                        final confirmed = await showDeleteConfirmationDialog(
                          context: context,
                          title: 'Delete Account?',
                          content:
                          'Are you sure you want to permanently delete this account?',
                        );
                        if (confirmed) {
                          widget.onAccountDeleted(account.id);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}