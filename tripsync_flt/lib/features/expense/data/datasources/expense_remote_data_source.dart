import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/expense_model.dart';
import '../models/balance_model.dart';
import '../models/settlement_model.dart';
import '../models/trip_member_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getExpenses(int tripId);
  Future<BalanceResponseModel> getBalances(int tripId);
  Future<List<SettlementModel>> getSettlements(int tripId);
  Future<ExpenseModel> createExpense({
    required int tripId,
    required double amount,
    required String description,
    String? category,
    required List<int> involvedUserIds,
  });
  Future<void> createSettlement({
    required int tripId,
    required int toUserId,
    required double amount,
  });
  Future<List<TripMemberModel>> getTripMembers(int tripId);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final ApiClient _client;

  ExpenseRemoteDataSourceImpl(this._client);

  @override
  Future<List<ExpenseModel>> getExpenses(int tripId) async {
    final response = await _client.get<dynamic>(
      ApiEndpoints.expensesByTrip(tripId),
    );
    
    final data = response.data;
    if (data is List) {
      return data.map((e) => ExpenseModel.fromJson(e)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => ExpenseModel.fromJson(e))
          .toList();
    }
    return [];
  }

  @override
  Future<BalanceResponseModel> getBalances(int tripId) async {
    final response = await _client.get<dynamic>(
      ApiEndpoints.expensesBalances(tripId),
    );
    
    final data = response.data;
    
    if (data is Map) {
      final innerData = data['data'];
      
      if (innerData is List) {
        return BalanceResponseModel.fromSettlementList(innerData);
      }
      
      if (innerData is Map) {
        return BalanceResponseModel.fromJson(innerData as Map<String, dynamic>);
      }
      
      return BalanceResponseModel.fromJson(Map<String, dynamic>.from(data));
    }
    
    if (data is List) {
      return BalanceResponseModel.fromSettlementList(data);
    }
    
    throw Exception('Failed to load balances');
  }

  @override
  Future<List<SettlementModel>> getSettlements(int tripId) async {
    final response = await _client.get<dynamic>(
      ApiEndpoints.expensesSettlements(tripId),
    );
    
    final data = response.data;
    if (data is List) {
      return data.map((s) => SettlementModel.fromJson(s)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((s) => SettlementModel.fromJson(s))
          .toList();
    }
    return [];
  }

  @override
  Future<ExpenseModel> createExpense({
    required int tripId,
    required double amount,
    required String description,
    String? category,
    required List<int> involvedUserIds,
  }) async {
    final body = {
      'trip_id': tripId,
      'amount': amount,
      'description': description,
      'category': category,
      'currency': 'VND',
      'split_method': 'equal',
      'involved_user_ids': involvedUserIds,
    };

    final response = await _client.post<dynamic>(
      ApiEndpoints.expenses,
      data: body,
    );

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return ExpenseModel.fromJson(data['data']);
    }
    throw Exception('Failed to create expense');
  }

  @override
  Future<void> createSettlement({
    required int tripId,
    required int toUserId,
    required double amount,
  }) async {
    final body = {
      'trip_id': tripId,
      'receiver_id': toUserId,
      'amount': amount,
    };

    await _client.post<dynamic>(
      ApiEndpoints.expensesSettle,
      data: body,
    );
  }

  @override
  Future<List<TripMemberModel>> getTripMembers(int tripId) async {
    final response = await _client.get<dynamic>(
      '${ApiEndpoints.trips}/$tripId/members',
    );
    
    final data = response.data;
    if (data is List) {
      return data.map((m) => TripMemberModel.fromJson(m)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((m) => TripMemberModel.fromJson(m))
          .toList();
    }
    return [];
  }
}
