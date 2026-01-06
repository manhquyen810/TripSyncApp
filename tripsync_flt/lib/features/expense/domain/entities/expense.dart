class Expense {
  final int id;
  final int tripId;
  final int payerId;
  final String payerName;
  final double amount;
  final String currency;
  final String? description;
  final String? category;
  final String splitMethod;
  final DateTime expenseDate;
  final List<ExpenseSplit> splits;

  const Expense({
    required this.id,
    required this.tripId,
    required this.payerId,
    required this.payerName,
    required this.amount,
    required this.currency,
    this.description,
    this.category,
    required this.splitMethod,
    required this.expenseDate,
    required this.splits,
  });
}

class ExpenseSplit {
  final int userId;
  final String userName;
  final double amountOwed;

  const ExpenseSplit({
    required this.userId,
    required this.userName,
    required this.amountOwed,
  });
}
