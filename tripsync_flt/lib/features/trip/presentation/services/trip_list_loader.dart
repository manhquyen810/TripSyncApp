import '../../../../core/config/env.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import 'trip_cover_images.dart';
import 'trip_cover_store.dart';

class TripListLoader {
  const TripListLoader._();

  static final Map<int, _TripMembersSnapshot> _membersCache =
      <int, _TripMembersSnapshot>{};

  static void invalidateMembersCache({int? tripId}) {
    if (tripId == null) {
      _membersCache.clear();
      return;
    }
    _membersCache.remove(tripId);
  }

  static void setMembersSnapshot({
    required int tripId,
    required int memberCount,
    required List<String> avatarUrls,
  }) {
    _membersCache[tripId] = _TripMembersSnapshot(
      memberCount: memberCount,
      avatarUrls: List<String>.from(avatarUrls),
    );
  }

  static int? getCachedMemberCount(int tripId) {
    return _membersCache[tripId]?.memberCount;
  }

  static List<String>? getCachedMemberAvatarUrls(int tripId) {
    return _membersCache[tripId]?.avatarUrls;
  }

  static Future<List<Trip>> loadTrips(TripRepository repository) async {
    final raw = await repository.listTrips();
    final data = raw['data'];
    if (data is List) {
      final coverById = await TripCoverStore.loadAll();
      final trips = mapTrips(data, coverById: coverById);
      return _enrichTripsWithMembers(trips, repository);
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

      final tripId = _parseTripId(
        tripJson['id'] ?? tripJson['trip_id'] ?? tripJson['tripId'],
      );

      final name = (tripJson['name'] ?? '').toString().trim();
      if (name.isEmpty) continue;

      final destination = (tripJson['destination'] ?? '').toString().trim();
      final startDate = _formatDateForUi(
        (tripJson['start_date'] ?? '').toString(),
      );
      final endDate = _formatDateForUi((tripJson['end_date'] ?? '').toString());

      final memberAvatarUrls = _extractMemberAvatarUrls(
        tripJson,
        containerJson: json,
      );
      final memberCount = _extractMemberCount(
        tripJson,
        containerJson: json,
        fallback: 1,
      );

      final serverCover = _extractServerCoverUrl(tripJson);

      final inviteCodeKey = _parseTripKey(tripJson['invite_code']);
      final inviteCode = inviteCodeKey ?? '';
      final savedCoverById = tripKey != null ? coverById[tripKey] : null;
      final savedCover = (savedCoverById != null && savedCoverById.isNotEmpty)
          ? savedCoverById
          : (inviteCodeKey != null ? coverById[inviteCodeKey] : null);
      final fallbackCover =
          TripCoverImages.assets[i % TripCoverImages.assets.length];

      trips.add(
        Trip(
          id: tripId,
          title: name,
          location: destination.isEmpty ? '—' : destination,
          imageUrl: _normalizeCover(
            (serverCover != null && serverCover.isNotEmpty)
                ? serverCover
                : ((savedCover != null && savedCover.isNotEmpty)
                      ? savedCover
                      : fallbackCover),
          ),
          inviteCode: inviteCode,
          memberCount: memberCount,
          memberAvatarUrls: memberAvatarUrls,
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

  static int? _parseTripId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim());
  }

  static Future<List<Trip>> _enrichTripsWithMembers(
    List<Trip> trips,
    TripRepository repository,
  ) async {
    if (trips.isEmpty) return trips;

    final futures = <Future<_TripMembersResult>>[];
    for (var i = 0; i < trips.length; i++) {
      final trip = trips[i];
      final id = trip.id;
      if (id == null || id <= 0) continue;
      futures.add(_loadMembersForTrip(repository, id, index: i));
    }

    if (futures.isEmpty) return trips;

    final results = await Future.wait(futures);
    if (results.isEmpty) return trips;

    final updated = List<Trip>.from(trips);
    for (final r in results) {
      if (!r.success) continue;
      final i = r.index;
      if (i < 0 || i >= updated.length) continue;
      final current = updated[i];

      final nextCount = r.memberCount ?? current.memberCount;
      final nextUrls = (r.avatarUrls != null && r.avatarUrls!.isNotEmpty)
          ? r.avatarUrls!
          : current.memberAvatarUrls;

      if (nextCount == current.memberCount &&
          _listEquals(nextUrls, current.memberAvatarUrls)) {
        continue;
      }

      updated[i] = Trip(
        id: current.id,
        title: current.title,
        location: current.location,
        imageUrl: current.imageUrl,
        inviteCode: current.inviteCode,
        memberCount: nextCount,
        memberAvatarUrls: nextUrls,
        memberColors: current.memberColors,
        startDate: current.startDate,
        endDate: current.endDate,
        daysCount: current.daysCount,
        confirmedCount: current.confirmedCount,
        proposedCount: current.proposedCount,
      );
    }

    return updated;
  }

  static Future<_TripMembersResult> _loadMembersForTrip(
    TripRepository repository,
    int tripId, {
    required int index,
  }) async {
    final cached = _membersCache[tripId];
    if (cached != null) {
      return _TripMembersResult(
        index: index,
        success: true,
        memberCount: cached.memberCount,
        avatarUrls: cached.avatarUrls,
      );
    }

    try {
      final raw = await repository.listTripMembers(tripId: tripId);
      final members = _extractMembersFromMembersResponse(raw);
      final urls = _extractAvatarUrlsFromMemberList(members);

      final snapshot = _TripMembersSnapshot(
        memberCount: members.length,
        avatarUrls: urls,
      );
      _membersCache[tripId] = snapshot;

      return _TripMembersResult(
        index: index,
        success: true,
        memberCount: snapshot.memberCount,
        avatarUrls: snapshot.avatarUrls,
      );
    } catch (_) {
      return _TripMembersResult(index: index, success: false);
    }
  }

  static List<Map<String, dynamic>> _extractMembersFromMembersResponse(
    Map<String, dynamic> raw,
  ) {
    final data = raw['data'];

    List<dynamic>? list;
    if (data is List) {
      list = data;
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data as Map);
      for (final key in const <String>[
        'members',
        'participants',
        'users',
        'data',
      ]) {
        final v = map[key];
        if (v is List) {
          list = v;
          break;
        }
      }
    }

    if (list == null) return const <Map<String, dynamic>>[];

    final out = <Map<String, dynamic>>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        out.add(item);
      } else if (item is Map) {
        out.add(Map<String, dynamic>.from(item as Map));
      }
    }
    return out;
  }

  static List<String> _extractAvatarUrlsFromMemberList(
    List<Map<String, dynamic>> members,
  ) {
    const avatarKeys = <String>[
      'avatar_url',
      'avatarUrl',
      'avatar',
      'photo_url',
      'photoUrl',
      'photo',
      'profile_image_url',
      'profileImageUrl',
      'profile_picture_url',
      'profilePictureUrl',
      'image_url',
      'imageUrl',
    ];

    final urls = <String>[];
    for (final m in members) {
      final nestedUser = m['user'] ?? m['profile'] ?? m['member'];
      final userMap = nestedUser is Map
          ? Map<String, dynamic>.from(nestedUser as Map)
          : null;

      String? found;
      for (final key in avatarKeys) {
        final v = m[key] ?? userMap?[key];
        if (v == null) continue;
        final s = v.toString().trim();
        if (s.isEmpty || s.toLowerCase() == 'null') continue;
        found = s;
        break;
      }

      if (found != null) {
        urls.add(_normalizeMediaUrl(found));
      }
    }

    return urls;
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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

  static int _extractMemberCount(
    Map<String, dynamic> tripJson, {
    Map<String, dynamic>? containerJson,
    int fallback = 1,
  }) {
    const countKeys = <String>[
      'member_count',
      'memberCount',
      'members_count',
      'membersCount',
      'participants_count',
      'participantsCount',
      'user_count',
      'userCount',
    ];

    for (final key in countKeys) {
      final v = tripJson[key] ?? containerJson?[key];
      if (v == null) continue;
      if (v is num) return v.toInt();
      final parsed = int.tryParse(v.toString().trim());
      if (parsed != null) return parsed;
    }

    final members = _extractMemberList(tripJson);
    if (members != null) return members.length;

    final containerMembers = containerJson != null
        ? _extractMemberList(containerJson)
        : null;
    if (containerMembers != null) return containerMembers.length;
    return fallback;
  }

  static List<String> _extractMemberAvatarUrls(
    Map<String, dynamic> tripJson, {
    Map<String, dynamic>? containerJson,
  }) {
    const avatarKeys = <String>[
      'avatar_url',
      'avatarUrl',
      'avatar',
      'photo_url',
      'photoUrl',
      'photo',
      'profile_image_url',
      'profileImageUrl',
      'profile_picture_url',
      'profilePictureUrl',
      'image_url',
      'imageUrl',
    ];

    final members =
        _extractMemberList(tripJson) ??
        (containerJson != null ? _extractMemberList(containerJson) : null);

    if (members != null && members.isNotEmpty) {
      final urls = <String>[];
      for (final item in members) {
        if (item is! Map) continue;
        final m = Map<String, dynamic>.from(item as Map);

        // Some payloads nest user info.
        final nestedUser = m['user'] ?? m['profile'] ?? m['member'];
        final userMap = nestedUser is Map
            ? Map<String, dynamic>.from(nestedUser as Map)
            : null;

        String? found;
        for (final key in avatarKeys) {
          final v = m[key] ?? userMap?[key];
          if (v == null) continue;
          final s = v.toString().trim();
          if (s.isEmpty || s.toLowerCase() == 'null') continue;
          found = s;
          break;
        }

        if (found != null) {
          urls.add(_normalizeMediaUrl(found));
        }
      }

      return urls;
    }

    // Fallback: if API returns an owner/user object or direct owner avatar field.
    final ownerUrl = _extractOwnerAvatarUrl(
      tripJson,
      containerJson: containerJson,
      avatarKeys: avatarKeys,
    );
    if (ownerUrl != null) {
      return <String>[_normalizeMediaUrl(ownerUrl)];
    }

    return const <String>[];
  }

  static String? _extractOwnerAvatarUrl(
    Map<String, dynamic> tripJson, {
    required List<String> avatarKeys,
    Map<String, dynamic>? containerJson,
  }) {
    const ownerAvatarKeys = <String>['owner_avatar_url', 'ownerAvatarUrl'];

    for (final key in ownerAvatarKeys) {
      final v = tripJson[key] ?? containerJson?[key];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty && s.toLowerCase() != 'null') return s;
    }

    final owner =
        tripJson['owner'] ??
        tripJson['user'] ??
        containerJson?['owner'] ??
        containerJson?['user'];
    if (owner is Map) {
      final ownerMap = Map<String, dynamic>.from(owner as Map);
      for (final key in avatarKeys) {
        final v = ownerMap[key];
        if (v == null) continue;
        final s = v.toString().trim();
        if (s.isNotEmpty && s.toLowerCase() != 'null') return s;
      }
    }

    return null;
  }

  static List<dynamic>? _extractMemberList(Map<String, dynamic> tripJson) {
    const memberListKeys = <String>[
      'members',
      'member_list',
      'memberList',
      'participants',
      'participant_list',
      'participantList',
      'users',
      'user_list',
      'userList',
    ];

    for (final key in memberListKeys) {
      final v = tripJson[key];
      if (v is List) return v;
    }
    return null;
  }

  static String _normalizeMediaUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('//')) return 'https:$trimmed';
    if (trimmed.startsWith('assets/')) return trimmed;

    if (trimmed.startsWith('/')) return '${Env.apiBaseUrl}$trimmed';
    return '${Env.apiBaseUrl}/$trimmed';
  }
}

class _TripMembersSnapshot {
  final int memberCount;
  final List<String> avatarUrls;

  const _TripMembersSnapshot({
    required this.memberCount,
    required this.avatarUrls,
  });
}

class _TripMembersResult {
  final int index;
  final bool success;
  final int? memberCount;
  final List<String>? avatarUrls;

  const _TripMembersResult({
    required this.index,
    required this.success,
    this.memberCount,
    this.avatarUrls,
  });
}
