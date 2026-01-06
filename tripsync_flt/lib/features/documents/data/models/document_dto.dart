class DocumentDto {
  final int id;
  final int tripId;
  final int uploaderId;
  final String filename;
  final String url;
  final String? category;
  final DateTime? createdAt;

  const DocumentDto({
    required this.id,
    required this.tripId,
    required this.uploaderId,
    required this.filename,
    required this.url,
    this.category,
    this.createdAt,
  });

  factory DocumentDto.fromJson(Map<String, dynamic> json) {
    int readInt(String key, {int fallback = 0}) {
      final v = json[key];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    String readString(String key) {
      final v = json[key];
      if (v is String) return v;
      return v?.toString() ?? '';
    }

    DateTime? readDateTime(String key) {
      final v = json[key];
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    return DocumentDto(
      id: readInt('id'),
      tripId: readInt('trip_id'),
      uploaderId: readInt('uploader_id'),
      filename: readString('filename'),
      url: readString('url'),
      category: json['category'] is String
          ? (json['category'] as String)
          : null,
      createdAt: readDateTime('created_at'),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'trip_id': tripId,
      'uploader_id': uploaderId,
      'filename': filename,
      'url': url,
      'category': category,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
