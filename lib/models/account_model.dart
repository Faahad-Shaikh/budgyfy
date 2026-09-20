import 'dart:convert';

class AccountModel {
  final String id;
  final String name;
  final double initialBalance;
  double balance;

  AccountModel({
    required this.id,
    required this.name,
    required this.initialBalance,
    double? balance,
  }) : balance = balance ?? initialBalance;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'initialBalance': initialBalance,
      'balance': balance,
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'],
      name: map['name'],
      initialBalance: (map['initialBalance'] as num).toDouble(),
      balance: (map['balance'] as num).toDouble(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory AccountModel.fromJson(String source) =>
      AccountModel.fromMap(jsonDecode(source));



  // Static method to generate dummy accounts
  static List<AccountModel> getDummyAccounts() {
    return [
      AccountModel(
        id: 'all',
        name: 'All Accounts',
        initialBalance: 0.0,
      ),
      AccountModel(
        id: 'acc_cash',
        name: 'Cash',
        initialBalance: 0.0,
      ),
      AccountModel(
        id: 'acc_online',
        name: 'Online',
        initialBalance: 0.0,
      ),
    ];
  }
}