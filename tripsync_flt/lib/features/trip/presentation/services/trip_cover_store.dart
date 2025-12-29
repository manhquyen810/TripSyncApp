import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TripCoverStore {
  const TripCoverStore._();

  static const String _kTripCoverById = 'trip.coverById';

  static Future<void> saveCoverAssetForTripId({
    required int tripId,
    required String assetPath,
  }) async {
    if (tripId <= 0) return;
    await saveCoverAssetForTripKey(
      tripKey: tripId.toString(),
      assetPath: assetPath,
    );
  }

  static Future<void> saveCoverAssetForTripKey({
    required String tripKey,
    required String assetPath,
  }) async {
    final key = tripKey.trim();
    if (key.isEmpty || key.toLowerCase() == 'null') return;

    final path = assetPath.trim();
    if (path.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final map = await loadAll();
    map[key] = path;

    final encoded = jsonEncode(map);
    await prefs.setString(_kTripCoverById, encoded);
  }

  static Future<Map<String, String>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kTripCoverById);
    if (raw == null || raw.trim().isEmpty) return <String, String>{};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, String>{};

      final result = <String, String>{};
      decoded.forEach((key, value) {
        final k = key.toString().trim();
        final path = value?.toString().trim();
        if (k.isNotEmpty &&
            k.toLowerCase() != 'null' &&
            path != null &&
            path.isNotEmpty) {
          result[k] = path;
        }
      });
      return result;
    } catch (_) {
      return <String, String>{};
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTripCoverById);
  }
}
