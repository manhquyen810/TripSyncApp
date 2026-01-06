import '../../domain/entities/expense.dart';

class ExpenseModel {
  final int id;
  final int tripId;
  final int payerId;
  final double amount;
  final String currency;
  final String? description;
  final String? category;
  final String splitMethod;
  final String expenseDate;
  final List<ExpenseSplitModel>? splits;
  final PayerModel? payer;

  ExpenseModel({
    required this.id,
    required this.tripId,
    required this.payerId,
    required this.amount,
    required this.currency,
    this.description,
    this.category,
    required this.splitMethod,
    required this.expenseDate,
    this.splits,
    this.payer,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      tripId: json['trip_id'],
      payerId: json['payer_id'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'VND',
      description: json['description'],
      category: json['category'],
      splitMethod: json['split_method'] ?? 'equal',
      expenseDate: json['expense_date'],
      splits: json['splits'] != null
          ? (json['splits'] as List)
                .map((s) => ExpenseSplitModel.fromJson(s))
                .toList()
          : null,
      payer: json['payer'] != null ? PayerModel.fromJson(json['payer']) : null,
    );
  }

  Expense toEntity() {
    return Expense(
      id: id,
      tripId: tripId,
      payerId: payerId,
      payerName: payer?.name ?? 'Unknown',
      amount: amount,
      currency: currency,
      description: description,
      category: category,
      splitMethod: splitMethod,
      expenseDate: DateTime.parse(expenseDate),
      splits: splits?.map((s) => s.toEntity()).toList() ?? [],
    );
  }
}

class ExpenseSplitModel {
  final int userId;
  final double amountOwed;
  final UserModel? user;

  ExpenseSplitModel({
    required this.userId,
    required this.amountOwed,
    this.user,
  });

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) {
    return ExpenseSplitModel(
      userId: json['user_id'],
      amountOwed: (json['amount_owed'] as num).toDouble(),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  ExpenseSplit toEntity() {
    return ExpenseSplit(
      userId: userId,
      userName: user?.name ?? 'Unknown',
      amountOwed: amountOwed,
    );
  }
}

class PayerModel {
  final int id;
  final String name;

  PayerModel({required this.id, required this.name});

  factory PayerModel.fromJson(Map<String, dynamic> json) {
    return PayerModel(id: json['id'], name: json['name']);
  }
}

class UserModel {
  final int id;
  final String name;

  UserModel({required this.id, required this.name});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'], name: json['name']);
  }
}
