class ChecklistItemDto {
  final int id;
  final int tripId;
  final String content;
  final int? assigneeId;
  final bool isDone;
  final DateTime? createdAt;

  const ChecklistItemDto({
    required this.id,
    required this.tripId,
    required this.content,
    required this.assigneeId,
    required this.isDone,
    required this.createdAt,
  });

  factory ChecklistItemDto.fromJson(Map<String, dynamic> json) {
    int readInt(String key, {int? fallback}) {
      final v = json[key];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? (fallback ?? 0);
      return fallback ?? 0;
    }

    bool readBool(String key, {bool fallback = false}) {
      final v = json[key];
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        final s = v.trim().toLowerCase();
        if (s == 'true' || s == '1') return true;
        if (s == 'false' || s == '0') return false;
      }
      return fallback;
    }

    String readString(String key, {String fallback = ''}) {
      final v = json[key];
      if (v is String) return v;
      return v?.toString() ?? fallback;
    }

    DateTime? readDateTime(String key) {
      final v = json[key];
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    final assigneeRaw = json['assignee'];
    int? assigneeId;
    if (assigneeRaw is int) {
      assigneeId = assigneeRaw;
    } else if (assigneeRaw is num) {
      assigneeId = assigneeRaw.toInt();
    } else if (assigneeRaw is String) {
      assigneeId = int.tryParse(assigneeRaw);
    }

    return ChecklistItemDto(
      id: readInt('id'),
      tripId: readInt('trip_id'),
      content: readString('content'),
      assigneeId: assigneeId,
      isDone: readBool('is_done'),
      createdAt: readDateTime('created_at'),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'trip_id': tripId,
      'content': content,
      'assignee': assigneeId,
      'is_done': isDone,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
