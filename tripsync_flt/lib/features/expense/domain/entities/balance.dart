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

  const BalanceResponse({
    required this.totalExpense,
    required this.balances,
  });
}
