import 'package:tripsync_flt/core/config/env.dart';
import 'dart:typed_data';

import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_data_source.dart';

class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl(this._remote);

  final TripRemoteDataSource _remote;

  @override
  Future<Map<String, dynamic>> listTrips() {
    return _remote.listTrips();
  }

  @override
  Future<Map<String, dynamic>> getTripDetail({required int tripId}) {
    return _remote.getTripDetail(tripId: tripId);
  }

  @override
  Future<Map<String, dynamic>> listTripMembers({required int tripId}) {
    return _remote.listTripMembers(tripId: tripId);
  }

  @override
  Future<Map<String, dynamic>> addTripMember({
    required int tripId,
    required String userEmail,
  }) {
    return _remote.addTripMember(tripId: tripId, userEmail: userEmail);
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
  }) {
    return _remote.createTrip(
      name: name,
      destination: destination,
      description: description,
      coverImageUrl: coverImageUrl,
      startDate: startDate,
      endDate: endDate,
      baseCurrency: baseCurrency,
    );
  }

  @override
  Future<Map<String, dynamic>> joinTrip({required String inviteCode}) {
    return _remote.joinTrip(inviteCode: inviteCode);
  }

  @override
  Future<String> uploadTripCover({
    required int tripId,
    String? filePath,
    Uint8List? bytes,
    String? filename,
  }) async {
    if ((bytes == null || bytes.isEmpty) &&
        (filePath == null || filePath.trim().isEmpty)) {
      throw ArgumentError('Either bytes or filePath must be provided');
    }

    final response = await _remote.uploadTripCover(
      tripId: tripId,
      filePath: filePath,
      bytes: bytes,
      filename: filename,
    );
    return _extractUploadedUrl(response);
  }

  @override
  Future<Map<String, dynamic>> updateTripCover({
    required int tripId,
    required String coverImageUrl,
  }) {
    return _remote.updateTrip(
      tripId: tripId,
      payload: <String, dynamic>{'cover_image_url': coverImageUrl},
    );
  }

  @override
  Future<Map<String, dynamic>> deleteTrip({required int tripId}) {
    return _remote.deleteTrip(tripId: tripId);
  }

  String _extractUploadedUrl(Map<String, dynamic> raw) {
    dynamic data = raw['data'];
    if (data is String && data.isNotEmpty) return _normalizeUrl(data);

    if (data is Map) {
      final map = Map<String, dynamic>.from(data as Map);
      const candidates = <String>[
        'url',
        'file_url',
        'fileUrl',
        'download_url',
        'downloadUrl',
        'public_url',
        'publicUrl',
        'path',
        'file_path',
        'filePath',
      ];

      for (final key in candidates) {
        final v = map[key];
        if (v is String && v.isNotEmpty) return _normalizeUrl(v);
      }

      for (final containerKey in const <String>['file', 'document', 'result']) {
        final nested = map[containerKey];
        if (nested is Map) {
          final nestedMap = Map<String, dynamic>.from(nested as Map);
          for (final key in candidates) {
            final v = nestedMap[key];
            if (v is String && v.isNotEmpty) return _normalizeUrl(v);
          }
        }
      }
    }

    throw StateError('Upload response did not contain a file URL');
  }

  String _normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('//')) {
      return 'https:$trimmed';
    }
    if (trimmed.startsWith('assets/')) return trimmed;

    // Relative path from API -> prefix base URL.
    if (trimmed.startsWith('/')) {
      return '${Env.apiBaseUrl}$trimmed';
    }
    return '${Env.apiBaseUrl}/$trimmed';
  }
}
