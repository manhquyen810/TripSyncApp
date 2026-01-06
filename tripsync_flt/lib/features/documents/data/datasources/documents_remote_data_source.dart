import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/config/env.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

abstract interface class DocumentsRemoteDataSource {
  Future<Map<String, dynamic>> uploadDocument({
    required int tripId,
    required String category,
    String? filePath,
    Uint8List? bytes,
    String? filename,
  });

  Future<Map<String, dynamic>> listDocumentsByTrip({required int tripId});

  Future<Map<String, dynamic>> getDocument({required int documentId});

  Future<Map<String, dynamic>> deleteDocument({required int documentId});

  Future<Uint8List> downloadBytes({required String url});
}

class DocumentsRemoteDataSourceImpl implements DocumentsRemoteDataSource {
  DocumentsRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> uploadDocument({
    required int tripId,
    required String category,
    String? filePath,
    Uint8List? bytes,
    String? filename,
  }) async {
    final safePath = filePath?.trim();
    final hasPath = safePath != null && safePath.isNotEmpty;

    final hasBytes = bytes != null && bytes.isNotEmpty;
    if (!hasPath && !hasBytes) {
      throw ArgumentError('Either bytes or filePath must be provided');
    }

    final trimmedFilename = filename?.trim();
    final effectiveFilename =
        (trimmedFilename != null && trimmedFilename.isNotEmpty)
        ? trimmedFilename
        : hasPath
        ? safePath.split(RegExp(r'[\\/]+')).last
        : 'upload';

    final MultipartFile multipart;
    final safeBytes = bytes;
    if (safeBytes != null && safeBytes.isNotEmpty) {
      multipart = MultipartFile.fromBytes(
        safeBytes,
        filename: effectiveFilename,
      );
    } else {
      final path = safePath;
      if (path == null || path.isEmpty) {
        throw ArgumentError('Either bytes or filePath must be provided');
      }
      if (path.startsWith('content://')) {
        throw StateError(
          'Cannot upload from content URI without bytes. Pick file with withData=true or provide bytes.',
        );
      }
      multipart = await MultipartFile.fromFile(
        path,
        filename: effectiveFilename,
      );
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
  Future<Map<String, dynamic>> listDocumentsByTrip({
    required int tripId,
  }) async {
    final response = await _client.get<dynamic>(
      ApiEndpoints.documentsByTrip(tripId),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> getDocument({required int documentId}) async {
    final response = await _client.get<dynamic>(
      ApiEndpoints.documentDetail(documentId),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Map<String, dynamic>> deleteDocument({required int documentId}) async {
    final response = await _client.delete<dynamic>(
      ApiEndpoints.documentDetail(documentId),
    );
    return _asJsonMap(response.data);
  }

  @override
  Future<Uint8List> downloadBytes({required String url}) async {
    final trimmed = url.trim();
    final isApiHost =
        Env.apiBaseUrl.isNotEmpty && trimmed.startsWith(Env.apiBaseUrl);
    final skipAuth = !isApiHost;

    final response = await _client.rawDio.get<List<int>>(
      trimmed,
      options: Options(
        responseType: ResponseType.bytes,
        extra: <String, dynamic>{'skipAuth': skipAuth},
        headers: const <String, dynamic>{'Accept': '*/*'},
      ),
    );

    final data = response.data;
    if (data == null) return Uint8List(0);
    return Uint8List.fromList(data);
  }
}

Map<String, dynamic> _asJsonMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  return <String, dynamic>{'data': data};
}
