import 'dart:typed_data';

abstract interface class TripRepository {
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

  Future<Map<String, dynamic>> deleteTrip({required int tripId});
}
