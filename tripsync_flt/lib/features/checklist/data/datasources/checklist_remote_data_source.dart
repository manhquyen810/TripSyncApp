import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

abstract interface class ChecklistRemoteDataSource {
  Future<Map<String, dynamic>> addItem({
    required int tripId,
    required String content,
    int? assigneeId,
  });

  Future<Map<String, dynamic>> toggleItem({
    required int itemId,
    required bool isDone,
  });

  Future<Map<String, dynamic>> listTripChecklist({required int tripId});

  Future<Map<String, dynamic>> getItem({required int itemId});

  Future<Map<String, dynamic>> updateItem({
    required int itemId,
    required String content,
    int? assigneeId,
  });

  Future<void> deleteItem({required int itemId});
}

class ChecklistRemoteDataSourceImpl implements ChecklistRemoteDataSource {
  ChecklistRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> addItem({
    required int tripId,
    required String content,
    int? assigneeId,
  }) async {
    final response = await _client.post<dynamic>(
      ApiEndpoints.checklistAddItem,
      queryParameters: <String, dynamic>{
        'trip_id': tripId,
        'content': content,
        if (assigneeId != null) 'assignee': assigneeId,
      },
    );

    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> toggleItem({
    required int itemId,
    required bool isDone,
  }) async {
    final response = await _client.post<dynamic>(
      ApiEndpoints.checklistToggleItem(itemId),
      queryParameters: <String, dynamic>{'is_done': isDone},
    );

    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> listTripChecklist({required int tripId}) async {
    final response = await _client.get<dynamic>(
      ApiEndpoints.checklistTrip(tripId),
    );

    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> getItem({required int itemId}) async {
    final response = await _client.get<dynamic>(
      ApiEndpoints.checklistItemDetail(itemId),
    );

    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> updateItem({
    required int itemId,
    required String content,
    int? assigneeId,
  }) async {
    final response = await _client.put<dynamic>(
      ApiEndpoints.checklistItemDetail(itemId),
      queryParameters: <String, dynamic>{
        'content': content,
        if (assigneeId != null) 'assignee': assigneeId,
      },
    );

    return _asJsonMap(response.data);
  }

  @override
  Future<void> deleteItem({required int itemId}) async {
    await _client.delete<dynamic>(ApiEndpoints.checklistItemDetail(itemId));
  }
}

Map<String, dynamic> _asJsonMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  return <String, dynamic>{'data': data};
}
