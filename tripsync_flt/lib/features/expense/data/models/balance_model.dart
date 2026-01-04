import '../../domain/entities/balance.dart';

class BalanceModel {
  final int userId;
  final String name;
  final double balance;

  BalanceModel({
    required this.userId,
    required this.name,
    required this.balance,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      userId: json['user_id'],
      name: json['name'],
      balance: (json['balance'] as num).toDouble(),
    );
  }

  Balance toEntity() {
    return Balance(
      userId: userId,
      name: name,
      balance: balance,
    );
  }
}

class BalanceResponseModel {
  final double totalExpense;
  final List<BalanceModel> balances;
  final List<Map<String, dynamic>> settlements;

  BalanceResponseModel({
    required this.totalExpense,
    required this.balances,
    this.settlements = const [],
  });

  factory BalanceResponseModel.fromJson(Map<String, dynamic> json) {
    final settlementsList = (json['settlements'] as List?)?.map((s) {
      return {
        'from_user_name': s['from_user']?['name'] ?? 'Unknown',
        'to_user_name': s['to_user']?['name'] ?? 'Unknown',
        'amount': (s['amount'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList() ?? [];

    return BalanceResponseModel(
      totalExpense: (json['total_expense'] as num?)?.toDouble() ?? 0.0,
      balances: (json['balances'] as List?)
              ?.map((b) => BalanceModel.fromJson(b))
              .toList() ??
          [],
      settlements: settlementsList,
    );
  }

  factory BalanceResponseModel.fromSettlementList(List<dynamic> settlements) {
    final balanceMap = <int, double>{};
    final nameMap = <int, String>{};
    double total = 0.0;

    for (final item in settlements) {
      if (item is! Map) continue;
      final fromUser = item['from_user'];
      final toUser = item['to_user'];
      final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;

      total += amount;

      if (fromUser is Map) {
        final id = fromUser['id'] as int;
        final name = fromUser['name'] as String? ?? 'Unknown';
        balanceMap[id] = (balanceMap[id] ?? 0.0) - amount;
        nameMap[id] = name;
      }

      if (toUser is Map) {
        final id = toUser['id'] as int;
        final name = toUser['name'] as String? ?? 'Unknown';
        balanceMap[id] = (balanceMap[id] ?? 0.0) + amount;
        nameMap[id] = name;
      }
    }

    final balances = balanceMap.entries
        .map((e) => BalanceModel(
              userId: e.key,
              name: nameMap[e.key] ?? 'Unknown',
              balance: e.value,
            ))
        .toList();

    return BalanceResponseModel(
      totalExpense: total,
      balances: balances,
    );
  }

  BalanceResponse toEntity() {
    return BalanceResponse(
      totalExpense: totalExpense,
      balances: balances.map((b) => b.toEntity()).toList(),
      settlements: settlements.map((s) => SettlementSummary(
        fromUserName: s['from_user_name'] as String,
        toUserName: s['to_user_name'] as String,
        amount: s['amount'] as double,
      )).toList(),
    );
  }
}
