import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

abstract interface class TripRemoteDataSource {
  Future<Map<String, dynamic>> listTrips();

  Future<Map<String, dynamic>> createTrip({
    required String name,
    required String destination,
    String? description,
    String? coverImageUrl,
    required DateTime startDate,
    required DateTime endDate,
    String baseCurrency = 'VND',
  });

  Future<Map<String, dynamic>> joinTrip({required String inviteCode});

  Future<Map<String, dynamic>> uploadTripCover({
    required int tripId,
    required String filePath,
    String category = 'cover',
  });

  Future<Map<String, dynamic>> updateTrip({
    required int tripId,
    required Map<String, dynamic> payload,
  });
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  TripRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> listTrips() async {
    final response = await _client.get<dynamic>(ApiEndpoints.trips);
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> createTrip({
    required String name,
    required String destination,
    String? description,
    String? coverImageUrl,
    required DateTime startDate,
    required DateTime endDate,
    String baseCurrency = 'VND',
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'destination': destination,
      'start_date': _formatDate(startDate),
      'end_date': _formatDate(endDate),
      'base_currency': baseCurrency,
    };

    final desc = description?.trim();
    if (desc != null && desc.isNotEmpty) {
      body['description'] = desc;
    }

    final cover = coverImageUrl?.trim();
    if (cover != null && cover.isNotEmpty) {
      body['cover_image_url'] = cover;
    }

    final response = await _client.post<dynamic>(
      ApiEndpoints.trips,
      data: body,
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> joinTrip({required String inviteCode}) async {
    final response = await _client.post<dynamic>(
      ApiEndpoints.tripsJoin,
      data: <String, dynamic>{'invite_code': inviteCode},
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> uploadTripCover({
    required int tripId,
    required String filePath,
    String category = 'cover',
  }) async {
    final filename = filePath.split(RegExp(r'[\\/]+')).last;

    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: filename),
    });

    final response = await _client.post<dynamic>(
      ApiEndpoints.documentsUpload,
      queryParameters: <String, dynamic>{
        'trip_id': tripId,
        'category': category,
      },
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );

    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> updateTrip({
    required int tripId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _client.put<dynamic>(
      ApiEndpoints.tripDetail(tripId),
      data: payload,
    );
    return _asJsonMap(response.data);
  }
}

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

Map<String, dynamic> _asJsonMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  return <String, dynamic>{'data': data};
}
