import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';

abstract interface class TripRemoteDataSource {
  Future<Map<String, dynamic>> listTrips();

  Future<Map<String, dynamic>> getTripDetail({required int tripId});

  Future<Map<String, dynamic>> listTripMembers({required int tripId});

  Future<Map<String, dynamic>> addTripMember({
    required int tripId,
    required String userEmail,
  });

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
    String? filePath,
    Uint8List? bytes,
    String? filename,
    String category = 'cover',
  });

  Future<Map<String, dynamic>> updateTrip({
    required int tripId,
    required Map<String, dynamic> payload,
  });

  Future<Map<String, dynamic>> deleteTrip({required int tripId});
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
  Future<Map<String, dynamic>> getTripDetail({required int tripId}) async {
    final response = await _client.get<dynamic>(
      ApiEndpoints.tripDetail(tripId),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> listTripMembers({required int tripId}) async {
    final response = await _client.get<dynamic>(
      ApiEndpoints.tripMembers(tripId),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> addTripMember({
    required int tripId,
    required String userEmail,
  }) async {
    final response = await _client.post<dynamic>(
      ApiEndpoints.tripMembers(tripId),
      data: <String, dynamic>{'user_email': userEmail},
    );
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
    String? filePath,
    Uint8List? bytes,
    String? filename,
    String category = 'cover',
  }) async {
    final safePath = filePath?.trim();
    final safeName = (filename?.trim().isNotEmpty == true)
        ? filename!.trim()
        : (safePath != null && safePath.isNotEmpty)
        ? safePath.split(RegExp(r'[\\/]+')).last
        : 'upload.jpg';

    final MultipartFile multipart;
    if (bytes != null && bytes.isNotEmpty) {
      multipart = MultipartFile.fromBytes(bytes, filename: safeName);
    } else {
      if (safePath == null || safePath.isEmpty) {
        throw ArgumentError('Either bytes or filePath must be provided');
      }
      if (safePath.startsWith('content://')) {
        throw StateError(
          'Cannot upload from content URI without bytes. Pick file with withData=true or provide bytes.',
        );
      }
      multipart = await MultipartFile.fromFile(safePath, filename: safeName);
    }

    final form = FormData.fromMap({'file': multipart});

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

  @override
  Future<Map<String, dynamic>> deleteTrip({required int tripId}) async {
    final response = await _client.delete<dynamic>(
      ApiEndpoints.tripDetail(tripId),
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
