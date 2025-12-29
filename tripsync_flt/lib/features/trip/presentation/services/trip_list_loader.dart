import '../../../../core/config/env.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import 'trip_cover_images.dart';
import 'trip_cover_store.dart';

class TripListLoader {
  const TripListLoader._();

  static Future<List<Trip>> loadTrips(TripRepository repository) async {
    final raw = await repository.listTrips();
    final data = raw['data'];
    if (data is List) {
      final coverById = await TripCoverStore.loadAll();
      return mapTrips(data, coverById: coverById);
    }
    return const <Trip>[];
  }

  static List<Trip> mapTrips(
    List<dynamic> data, {
    required Map<String, String> coverById,
  }) {
    final trips = <Trip>[];
    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      if (item is! Map) continue;
      final json = Map<String, dynamic>.from(item as Map);
      final tripJson = _extractTripJson(json);

      final tripKey = _parseTripKey(
        tripJson['id'] ?? tripJson['trip_id'] ?? tripJson['tripId'],
      );

      final name = (tripJson['name'] ?? '').toString().trim();
      if (name.isEmpty) continue;

      final destination = (tripJson['destination'] ?? '').toString().trim();
      final startDate = _formatDateForUi(
        (tripJson['start_date'] ?? '').toString(),
      );
      final endDate = _formatDateForUi((tripJson['end_date'] ?? '').toString());

      final serverCover = _extractServerCoverUrl(tripJson);

      final inviteCodeKey = _parseTripKey(tripJson['invite_code']);
      final savedCoverById = tripKey != null ? coverById[tripKey] : null;
      final savedCover = (savedCoverById != null && savedCoverById.isNotEmpty)
          ? savedCoverById
          : (inviteCodeKey != null ? coverById[inviteCodeKey] : null);
      final fallbackCover =
          TripCoverImages.assets[i % TripCoverImages.assets.length];

      trips.add(
        Trip(
          title: name,
          location: destination.isEmpty ? '—' : destination,
          imageUrl: _normalizeCover(
            (serverCover != null && serverCover.isNotEmpty)
                ? serverCover
                : ((savedCover != null && savedCover.isNotEmpty)
                      ? savedCover
                      : fallbackCover),
          ),
          memberCount: 1,
          memberColors: const ['#A8E6CF', '#E59600', '#FF6B6B'],
          startDate: startDate,
          endDate: endDate,
          daysCount: _estimateDays(startDate, endDate),
          confirmedCount: 0,
          proposedCount: 0,
        ),
      );
    }

    return trips;
  }

  static Map<String, dynamic> _extractTripJson(Map<String, dynamic> json) {
    if (json.containsKey('name') ||
        json.containsKey('destination') ||
        json.containsKey('start_date')) {
      return json;
    }

    final trip = json['trip'];
    if (trip is Map) {
      return Map<String, dynamic>.from(trip as Map);
    }

    return json;
  }

  static String? _extractServerCoverUrl(Map<String, dynamic> tripJson) {
    const keys = <String>[
      'cover_image_url',
      'coverImageUrl',
      'image_url',
      'imageUrl',
      'cover_url',
      'coverUrl',
      'cover',
    ];

    for (final k in keys) {
      final v = tripJson[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty && s.toLowerCase() != 'null') return s;
    }
    return null;
  }

  static String? _parseTripKey(dynamic value) {
    if (value == null) return null;
    final key = value.toString().trim();
    if (key.isEmpty || key.toLowerCase() == 'null') return null;
    return key;
  }

  static int _estimateDays(String start, String end) {
    try {
      final s = _parseUiDate(start);
      final e = _parseUiDate(end);
      if (s == null || e == null) return 1;
      final diff = e.difference(s).inDays;
      return (diff >= 0 ? diff + 1 : 1);
    } catch (_) {
      return 1;
    }
  }

  static DateTime? _parseUiDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;
    final d = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (d == null || m == null || y == null) return null;
    return DateTime(y, m, d);
  }

  static String _formatDateForUi(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length != 3) return isoDate;
    final y = parts[0];
    final m = parts[1];
    final d = parts[2];
    if (y.length != 4) return isoDate;
    return '$d/$m/$y';
  }

  static String _normalizeCover(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('//')) return 'https:$trimmed';
    if (trimmed.startsWith('assets/')) return trimmed;

    final lower = trimmed.toLowerCase();
    final isWindowsDrivePath = RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(trimmed);
    if (isWindowsDrivePath ||
        lower.contains(':/') ||
        lower.startsWith('\\') ||
        lower.startsWith('/storage/')) {
      return trimmed;
    }

    if (trimmed.startsWith('/')) return '${Env.apiBaseUrl}$trimmed';
    return '${Env.apiBaseUrl}/$trimmed';
  }
}
