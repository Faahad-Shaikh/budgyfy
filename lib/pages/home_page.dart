import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../services/local_storage_service.dart';
import '../widgets/account_drawer.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/category_modal.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/total_balance_card.dart';
import '../widgets/transaction_list.dart';
import '../widgets/transaction_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AccountModel> accounts = [];
  List<CategoryModel> categories = [];
  List<TransactionModel> transactions = [];
  AccountModel? selectedAccount;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final loadedAccounts = await LocalStorageService.loadAccounts();
    final loadedCategories = await LocalStorageService.loadCategories();
    final loadedTransactions = await LocalStorageService.loadTransactions();

    setState(() {
      accounts = loadedAccounts;
      categories = loadedCategories;
      transactions = loadedTransactions;

      selectedAccount = accounts.firstWhere(
            (acc) => acc.id == 'all',
        orElse: () => accounts.first,
      );
    });
  }

  double get displayedBalance {
    if (selectedAccount == null || selectedAccount!.id == 'all') {
      return accounts
          .where((acc) => acc.id != 'all')
          .fold(0.0, (sum, acc) => sum + acc.balance);
    }
    return selectedAccount!.balance;
  }

  double get aggregateTotalBalance {
    return accounts
        .where((acc) => acc.id != 'all')
        .fold(0.0, (sum, acc) => sum + acc.balance);
  }

  // --- TRANSACTION HANDLERS ---

  // 1. Opens Modal to Add a NEW Transaction
  void _openTransactionModal(TransactionType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return TransactionModal(
          initialType: type,
          accounts: accounts,
          categories: categories,
          selectedAccount: selectedAccount,
          onTransactionSaved: _addTransaction,
        );
      },
    );
  }

  // 2. Creates New Transaction & Adjusts Account Balance
  void _addTransaction(TransactionModel transaction) async {
    setState(() {
      transactions.add(transaction);

      final accountIndex = accounts.indexWhere((a) => a.id == transaction.accountId);
      if (accountIndex != -1) {
        if (transaction.type == TransactionType.expense) {
          accounts[accountIndex].balance -= transaction.amount;
        } else {
          accounts[accountIndex].balance += transaction.amount;
        }
      }
    });

    await LocalStorageService.saveTransactions(transactions);
    await LocalStorageService.saveAccounts(accounts);
  }

  // 3. Opens Modal to EDIT an Existing Transaction
  void _openEditTransactionModal(TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return TransactionModal(
          initialType: tx.type,
          accounts: accounts,
          categories: categories,
          selectedAccount: selectedAccount,
          existingTransaction: tx,
          onTransactionSaved: _updateTransaction,
        );
      },
    );
  }

  // 4. Updates Edited Transaction & Recalculates Account Balance
  void _updateTransaction(TransactionModel updatedTx) async {
    final oldTxIndex = transactions.indexWhere((t) => t.id == updatedTx.id);
    if (oldTxIndex == -1) return;

    final oldTx = transactions[oldTxIndex];

    setState(() {
      // Revert old transaction impact
      final oldAccIndex = accounts.indexWhere((a) => a.id == oldTx.accountId);
      if (oldAccIndex != -1) {
        if (oldTx.type == TransactionType.expense) {
          accounts[oldAccIndex].balance += oldTx.amount;
        } else {
          accounts[oldAccIndex].balance -= oldTx.amount;
        }
      }

      // Apply new transaction impact
      final newAccIndex = accounts.indexWhere((a) => a.id == updatedTx.accountId);
      if (newAccIndex != -1) {
        if (updatedTx.type == TransactionType.expense) {
          accounts[newAccIndex].balance -= updatedTx.amount;
        } else {
          accounts[newAccIndex].balance += updatedTx.amount;
        }
      }

      transactions[oldTxIndex] = updatedTx;
    });

    await LocalStorageService.saveTransactions(transactions);
    await LocalStorageService.saveAccounts(accounts);
  }

  // 5. Deletes Transaction & Reverts Balance
  void _deleteTransaction(String txId) async {
    final txIndex = transactions.indexWhere((t) => t.id == txId);
    if (txIndex == -1) return;

    final tx = transactions[txIndex];

    setState(() {
      final accIndex = accounts.indexWhere((a) => a.id == tx.accountId);
      if (accIndex != -1) {
        if (tx.type == TransactionType.expense) {
          accounts[accIndex].balance += tx.amount;
        } else {
          accounts[accIndex].balance -= tx.amount;
        }
      }

      transactions.removeAt(txIndex);
    });

    await LocalStorageService.saveTransactions(transactions);
    await LocalStorageService.saveAccounts(accounts);
  }

  // --- CATEGORY MODAL ---

  void _openCategoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return CategoryModal(
          categories: categories,
          onCategoryCreated: (newCat) async {
            setState(() => categories.add(newCat));
            await LocalStorageService.saveCategories(categories);
          },
          onCategoryDeleted: (catId) async {
            setState(() => categories.removeWhere((cat) => cat.id == catId));
            await LocalStorageService.saveCategories(categories);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const CustomAppBar(),
      drawer: AccountDrawer(
        accounts: accounts,
        selectedAccount: selectedAccount,
        totalBalance: aggregateTotalBalance,
        onAccountSelected: (acc) => setState(() => selectedAccount = acc),
        onAccountCreated: (newAcc) async {
          setState(() => accounts.add(newAcc));
          await LocalStorageService.saveAccounts(accounts);
        },
        onAccountDeleted: (accId) async {
          setState(() {
            accounts.removeWhere((acc) => acc.id == accId);
            if (selectedAccount?.id == accId) {
              selectedAccount = accounts.firstWhere(
                    (acc) => acc.id == 'all',
                orElse: () => accounts.first,
              );
            }
          });
          await LocalStorageService.saveAccounts(accounts);
        },
      ),
      body: ListView(
        children: [
          TotalBalanceCard(
            title: selectedAccount?.name ?? 'Total Balance',
            balance: displayedBalance,
          ),
          TransactionList(
            transactions: transactions,
            accounts: accounts,
            categories: categories,
            selectedAccount: selectedAccount,
            onDeleteTransaction: _deleteTransaction,
            onEditTransaction: _openEditTransactionModal,
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        onCategoryTap: _openCategoryModal,
        onAddTransactionTap: _openTransactionModal,
      ),
    );
  }
}