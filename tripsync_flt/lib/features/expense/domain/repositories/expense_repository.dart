import '../entities/expense.dart';
import '../entities/balance.dart';
import '../entities/settlement.dart';
import '../entities/trip_member.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses(int tripId);
  Future<BalanceResponse> getBalances(int tripId);
  Future<List<Settlement>> getSettlements(int tripId);
  Future<Expense> createExpense({
    required int tripId,
    required double amount,
    required String description,
    String? category,
    required int payerId,
    required List<int> involvedUserIds,
  });
  Future<void> createSettlement({
    required int tripId,
    required int toUserId,
    required double amount,
  });
  Future<List<TripMember>> getTripMembers(int tripId);
}
