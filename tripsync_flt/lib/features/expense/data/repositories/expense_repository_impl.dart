import '../../domain/entities/expense.dart';
import '../../domain/entities/balance.dart';
import '../../domain/entities/settlement.dart';
import '../../domain/entities/trip_member.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_data_source.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource _remoteDataSource;

  ExpenseRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Expense>> getExpenses(int tripId) async {
    final models = await _remoteDataSource.getExpenses(tripId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<BalanceResponse> getBalances(int tripId) async {
    final model = await _remoteDataSource.getBalances(tripId);
    return model.toEntity();
  }

  @override
  Future<List<Settlement>> getSettlements(int tripId) async {
    final models = await _remoteDataSource.getSettlements(tripId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Expense> createExpense({
    required int tripId,
    required double amount,
    required String description,
    String? category,
    required int payerId,
    required List<int> involvedUserIds,
  }) async {
    final model = await _remoteDataSource.createExpense(
      tripId: tripId,
      amount: amount,
      description: description,
      category: category,
      payerId: payerId,
      involvedUserIds: involvedUserIds,
    );
    return model.toEntity();
  }

  @override
  Future<void> createSettlement({
    required int tripId,
    required int toUserId,
    required double amount,
  }) async {
    await _remoteDataSource.createSettlement(
      tripId: tripId,
      toUserId: toUserId,
      amount: amount,
    );
  }

  @override
  Future<List<TripMember>> getTripMembers(int tripId) async {
    final models = await _remoteDataSource.getTripMembers(tripId);
    return models.map((m) => m.toEntity()).toList();
  }
}
