import 'dart:typed_data';

abstract interface class TripRepository {
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

  Future<String> uploadTripCover({
    required int tripId,
    String? filePath,
    Uint8List? bytes,
    String? filename,
  });

  Future<Map<String, dynamic>> updateTripCover({
    required int tripId,
    required String coverImageUrl,
  });
}
