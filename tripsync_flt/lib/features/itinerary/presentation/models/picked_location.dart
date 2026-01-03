class PickedLocation {
  final String label;
  final double latitude;
  final double longitude;
  final String? placeName;
  final String? address;

  const PickedLocation({
    required this.label,
    required this.latitude,
    required this.longitude,
    this.placeName,
    this.address,
  });

  Map<String, dynamic> toJson() => {
    'label': label,
    'latitude': latitude,
    'longitude': longitude,
    if (placeName != null) 'placeName': placeName,
    if (address != null) 'address': address,
  };
}
