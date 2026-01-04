class Balance {
  final int userId;
  final String name;
  final double balance;

  const Balance({
    required this.userId,
    required this.name,
    required this.balance,
  });
}

class BalanceResponse {
  final double totalExpense;
  final List<Balance> balances;
  final List<SettlementSummary> settlements;

  const BalanceResponse({
    required this.totalExpense,
    required this.balances,
    this.settlements = const [],
  });
}

class SettlementSummary {
  final String fromUserName;
  final String toUserName;
  final double amount;

  const SettlementSummary({
    required this.fromUserName,
    required this.toUserName,
    required this.amount,
  });
}
