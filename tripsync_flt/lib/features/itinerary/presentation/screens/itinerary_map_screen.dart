import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../../core/config/mapbox.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/auth_token_store.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../trip/domain/entities/trip.dart';

part '../widgets/itinerary_map_screen_widgets.dart';

class TripItineraryMapScreen extends StatefulWidget {
  final Trip trip;
  final int initialDayIndex;

  const TripItineraryMapScreen({
    super.key,
    required this.trip,
    this.initialDayIndex = 0,
  });

  @override
  State<TripItineraryMapScreen> createState() => _TripItineraryMapScreenState();
}

class _TripItineraryMapScreenState extends State<TripItineraryMapScreen> {
  int? _dayFilter; // null = all days, otherwise dayNumber (1-based)
  _DayActivities? _visibleActivities;

  late final ApiClient _apiClient;
  late Future<_DayActivities> _activitiesFuture;

  MapboxMap? _map;
  PointAnnotationManager? _confirmedManager;
  PointAnnotationManager? _proposedManager;
  PolylineAnnotationManager? _routeManager;
  CircleAnnotationManager? _myLocationManager;

  geo.Position? _myPosition;

  // Marker images are generated per (category + timeLabel) so each activity
  // can show its start time on the marker.
  final Map<String, Uint8List?> _confirmedMarkerByKey = <String, Uint8List?>{};
  final Map<String, Uint8List?> _proposedMarkerByKey = <String, Uint8List?>{};
  Uint8List? _confirmedMarkerFallback;
  Uint8List? _proposedMarkerFallback;

  _DayActivities? _lastActivities;
  _ActivityItem? _selectedActivity;
  Offset? _selectedActivityAnchorPx;

  bool _didInitialFit = false;

  Timer? _cameraDebounce;

  int _routeRequestId = 0;
  String? _lastRouteKey;

  static const double _defaultLat = 21.0278;
  static const double _defaultLng = 105.8342;
  static const double _defaultZoom = 2.6;

  Point get _defaultCenter =>
      Point(coordinates: Position(_defaultLng, _defaultLat));

  static bool get _isMapboxSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Trip get trip => widget.trip;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(authTokenProvider: AuthTokenStore.getAccessToken);
    _activitiesFuture = _loadActivitiesForTripAllDays();
    // Default: if caller provided initial day index, start filtered to that day.
    final initial = widget.initialDayIndex;
    if (initial >= 0 && initial < trip.daysCount) {
      _dayFilter = initial + 1;
    }
  }

  @override
  void didUpdateWidget(covariant TripItineraryMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trip.id != widget.trip.id) {
      _activitiesFuture = _loadActivitiesForTripAllDays();
    }
  }

  @override
  void dispose() {
    _cameraDebounce?.cancel();
    _confirmedManager = null;
    _proposedManager = null;
    _routeManager = null;
    _myLocationManager = null;
    _map = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: _isMapboxSupportedPlatform
                ? MapWidget(
                    styleUri: MapboxStyles.STANDARD,
                    cameraOptions: CameraOptions(
                      center: _defaultCenter,
                      zoom: _defaultZoom,
                    ),
                    onMapCreated: (mapboxMap) async {
                      _map = mapboxMap;
                      await _initAnnotationSupport();

                      if (!mounted) return;
                      final activities = await _activitiesFuture;
                      if (!mounted) return;
                      final visible = _applyDayFilter(activities);
                      await _syncMarkers(visible);
                      await _syncRoute(visible);
                      await _maybeFitCameraToActivities(visible);
                      if (!mounted) return;
                      setState(() {
                        _lastActivities = activities;
                        _visibleActivities = visible;
                      });
                      _scheduleSelectedAnchorRecompute();
                    },
                    onTapListener: _handleMapTap,
                    onCameraChangeListener: _handleCameraChange,
                    onMapIdleListener: _handleMapIdle,
                  )
                : const ColoredBox(color: AppColors.divider),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(color: Colors.white.withValues(alpha: 0.10)),
            ),
          ),
          if (_selectedActivity != null)
            Positioned.fill(
              child: IgnorePointer(
                child: _MarkerPopupLayer(
                  activity: _selectedActivity!,
                  anchorPx: _selectedActivityAnchorPx,
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderBar(
                    title: 'Bản đồ chuyến đi',
                    subtitle: trip.location,
                    onBack: () => Navigator.of(context).pop(),
                    onSearch: () {},
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<_DayActivities>(
                    future: _activitiesFuture,
                    builder: (context, snapshot) {
                      final data = _visibleActivities ?? snapshot.data;
                      final confirmed = data?.confirmed.length ?? 0;
                      final proposed = data?.proposed.length ?? 0;
                      return _LegendChips(
                        confirmedCount: confirmed,
                        proposedCount: proposed,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DayFilterDropdown(
                          daysCount: trip.daysCount,
                          value: _dayFilter,
                          onChanged: _setDayFilter,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 40,
            child: _MapControls(
              onLocate: _useMyLocation,
              onZoomIn: () => _zoomBy(1.0),
              onZoomOut: () => _zoomBy(-1.0),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMapTap(MapContentGestureContext context) async {
    final map = _map;
    final tapPx = context.touchPosition;

    _DayActivities? activities = _visibleActivities;
    if (activities == null) {
      try {
        final all = await _activitiesFuture;
        activities = _applyDayFilter(all);
      } catch (_) {
        activities = null;
      }
    }
    if (activities == null) {
      if (!mounted) return;
      setState(() {
        _selectedActivity = null;
        _selectedActivityAnchorPx = null;
      });
      return;
    }

    final all = <_ActivityItem>[
      ...activities.confirmed.where((a) => a.hasCoordinates),
      ...activities.proposed.where((a) => a.hasCoordinates),
    ];
    if (all.isEmpty) {
      if (!mounted) return;
      setState(() {
        _selectedActivity = null;
        _selectedActivityAnchorPx = null;
      });
      return;
    }

    _ActivityItem? best;
    double bestPx = double.infinity;
    Offset? bestAnchor;

    if (map != null) {
      for (final a in all) {
        final lat = a.latitude;
        final lng = a.longitude;
        if (lat == null || lng == null) continue;
        try {
          final sc = await map.pixelForCoordinate(
            Point(coordinates: Position(lng, lat)),
          );
          final dx = sc.x.toDouble() - tapPx.x.toDouble();
          final dy = sc.y.toDouble() - tapPx.y.toDouble();
          final d = sqrt(dx * dx + dy * dy);
          if (d < bestPx) {
            bestPx = d;
            best = a;
            bestAnchor = Offset(sc.x.toDouble(), sc.y.toDouble());
          }
        } catch (_) {
          // Ignore and keep trying others.
        }
      }
    }

    if (!mounted) return;

    // Pixel-based threshold is far more reliable than meters/zoom.
    const double thresholdPx = 52;
    if (best == null || bestPx > thresholdPx) {
      setState(() {
        _selectedActivity = null;
        _selectedActivityAnchorPx = null;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _selectedActivity = best;
      _selectedActivityAnchorPx = bestAnchor;
    });
    _scheduleSelectedAnchorRecompute();
  }

  Future<void> _setDayFilter(int? dayNumber) async {
    if (dayNumber == _dayFilter) return;
    setState(() {
      _dayFilter = dayNumber;
    });

    final all = _lastActivities;
    if (all != null) {
      final visible = _applyDayFilter(all);
      if (!mounted) return;
      setState(() {
        _visibleActivities = visible;
        // Clear selection if it no longer belongs to visible set.
        if (_selectedActivity != null &&
            !_isActivityVisible(_selectedActivity!, visible)) {
          _selectedActivity = null;
          _selectedActivityAnchorPx = null;
        }
      });
      await _syncMarkers(visible);
      await _syncRoute(visible);
      return;
    }

    try {
      final loaded = await _activitiesFuture;
      if (!mounted) return;
      final visible = _applyDayFilter(loaded);
      setState(() {
        _lastActivities = loaded;
        _visibleActivities = visible;
      });
      await _syncMarkers(visible);
      await _syncRoute(visible);
    } catch (_) {
      // Ignore.
    }
  }

  _DayActivities _applyDayFilter(_DayActivities all) {
    final day = _dayFilter;
    if (day == null) return all;
    return _DayActivities(
      confirmed: all.confirmed
          .where((a) => a.dayNumber == day)
          .toList(growable: false),
      proposed: all.proposed
          .where((a) => a.dayNumber == day)
          .toList(growable: false),
    );
  }

  bool _isActivityVisible(_ActivityItem a, _DayActivities visible) {
    // Match by coordinates + title/category/day as best-effort (no stable id in map item).
    return visible.confirmed.any((x) => _sameActivity(x, a)) ||
        visible.proposed.any((x) => _sameActivity(x, a));
  }

  bool _sameActivity(_ActivityItem a, _ActivityItem b) {
    final al = a.latitude;
    final ao = a.longitude;
    final bl = b.latitude;
    final bo = b.longitude;
    final coordsSame = al != null && ao != null && bl != null && bo != null
        ? (al - bl).abs() < 1e-6 && (ao - bo).abs() < 1e-6
        : false;
    return a.dayNumber == b.dayNumber && a.title == b.title && coordsSame;
  }

  void _handleCameraChange(CameraChangedEventData _) {
    _scheduleSelectedAnchorRecompute();
  }

  void _handleMapIdle(MapIdleEventData _) {
    _scheduleSelectedAnchorRecompute(delay: Duration.zero);
  }

  void _scheduleSelectedAnchorRecompute({
    Duration delay = const Duration(milliseconds: 50),
  }) {
    if (!mounted) return;
    if (_selectedActivity == null) return;
    if (_map == null) return;

    _cameraDebounce?.cancel();
    _cameraDebounce = Timer(delay, () {
      _recomputeSelectedAnchor();
    });
  }

  Future<void> _recomputeSelectedAnchor() async {
    final map = _map;
    final selected = _selectedActivity;
    if (!mounted || map == null || selected == null) return;
    if (selected.latitude == null || selected.longitude == null) return;

    try {
      final sc = await map.pixelForCoordinate(
        Point(coordinates: Position(selected.longitude!, selected.latitude!)),
      );
      if (!mounted) return;
      final next = Offset(sc.x.toDouble(), sc.y.toDouble());
      final prev = _selectedActivityAnchorPx;
      // Avoid noisy rebuilds if it barely changed.
      final changed = prev == null || (next - prev).distance > 0.5;
      if (changed) {
        setState(() {
          _selectedActivityAnchorPx = next;
        });
      }
    } catch (_) {
      // Best-effort.
    }
  }

  Future<void> _initAnnotationSupport() async {
    if (!_isMapboxSupportedPlatform) return;
    final map = _map;
    if (map == null) return;

    _confirmedManager ??= await map.annotations.createPointAnnotationManager();
    _proposedManager ??= await map.annotations.createPointAnnotationManager();
    _routeManager ??= await map.annotations.createPolylineAnnotationManager();
    _myLocationManager ??= await map.annotations
        .createCircleAnnotationManager();

    // Marker images are category-based and built on-demand.
  }

  String _normalizeCategoryKey(String raw) => raw.trim().toLowerCase();

  String _formatMinutesToHHmm(int minutes) {
    final h = (minutes ~/ 60).clamp(0, 23);
    final m = (minutes % 60).clamp(0, 59);
    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _markerKeyForActivity(_ActivityItem a) {
    final cat = _normalizeCategoryKey(a.category);
    final t = a.startMinutes == null
        ? ''
        : _formatMinutesToHHmm(a.startMinutes!);
    return '$cat|$t';
  }

  IconData _markerIconForCategory(String raw) {
    final s = raw.trim().toLowerCase();
    if (s.isEmpty) return LucideIcons.activity;
    if (s.contains('ăn') ||
        s.contains('food') ||
        s.contains('cafe') ||
        s.contains('restaurant')) {
      return LucideIcons.utensils;
    }
    if (s.contains('khách sạn') || s.contains('hotel')) {
      return LucideIcons.building;
    }
    if (s.contains('tham quan') ||
        s.contains('sight') ||
        s.contains('tour') ||
        s.contains('visit')) {
      return LucideIcons.camera;
    }
    if (s.contains('di chuyển') ||
        s.contains('transport') ||
        s.contains('move') ||
        s.contains('car')) {
      return LucideIcons.car;
    }
    return LucideIcons.activity;
  }

  Future<void> _ensureMarkerFallbacks() async {
    _confirmedMarkerFallback ??= await _buildIconImage(
      icon: LucideIcons.mapPin,
      color: AppColors.primary,
    );
    _proposedMarkerFallback ??= await _buildIconImage(
      icon: LucideIcons.mapPin,
      color: AppColors.accent,
    );
  }

  Future<geo.Position?> _getCurrentPosition() async {
    try {
      final enabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        throw Exception('Vui lòng bật định vị (GPS).');
      }

      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }
      if (permission == geo.LocationPermission.denied) {
        throw Exception('Bạn đã từ chối quyền truy cập vị trí.');
      }
      if (permission == geo.LocationPermission.deniedForever) {
        throw Exception('Quyền vị trí bị chặn. Hãy bật lại trong cài đặt.');
      }

      return await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
        ),
      );
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      return null;
    }
  }

  Future<void> _useMyLocation() async {
    final map = _map;
    if (map == null) return;

    final pos = await _getCurrentPosition();
    if (pos == null) return;
    _myPosition = pos;

    final lat = pos.latitude;
    final lng = pos.longitude;

    await _updateMyLocationMarker(
      lat: lat,
      lng: lng,
      accuracyMeters: pos.accuracy,
    );

    // Redraw route to include "my location" -> first activity.
    try {
      final all = _lastActivities ?? await _activitiesFuture;
      final visible = _visibleActivities ?? _applyDayFilter(all);
      await _syncRoute(visible);
    } catch (_) {
      // Best-effort.
    }

    try {
      await map.setCamera(
        CameraOptions(center: Point(coordinates: Position(lng, lat)), zoom: 14),
      );
    } catch (_) {
      // Best-effort.
    }
  }

  Future<void> _updateMyLocationMarker({
    required double lat,
    required double lng,
    double? accuracyMeters,
  }) async {
    if (!_isMapboxSupportedPlatform) return;
    final manager = _myLocationManager;
    if (manager == null) return;

    try {
      await manager.deleteAll();
    } catch (_) {
      // Ignore.
    }

    final point = Point(coordinates: Position(lng, lat));

    double haloRadiusPx = 40;
    final acc = accuracyMeters ?? 0;
    if (acc > 0) {
      haloRadiusPx = (acc * 0.6).clamp(24, 120).toDouble();
    }

    final halo = CircleAnnotationOptions(
      geometry: point,
      circleColor: AppColors.primary.toARGB32(),
      circleOpacity: 0.18,
      circleRadius: haloRadiusPx,
      circleBlur: 0.2,
    );

    final dot = CircleAnnotationOptions(
      geometry: point,
      circleColor: AppColors.primary.toARGB32(),
      circleOpacity: 1.0,
      circleRadius: 7,
      circleStrokeColor: 0xFFFFFFFF,
      circleStrokeOpacity: 1.0,
      circleStrokeWidth: 2,
    );

    try {
      await manager.createMulti([halo, dot]);
    } catch (_) {
      // Best-effort.
    }
  }

  Future<void> _syncRoute(_DayActivities activities) async {
    if (!_isMapboxSupportedPlatform) return;
    final manager = _routeManager;
    if (manager == null) return;

    try {
      await manager.deleteAll();
    } catch (_) {
      // Ignore.
    }

    final points = <_ActivityItem>[
      ...activities.confirmed.where((a) => a.hasCoordinates),
      ...activities.proposed.where((a) => a.hasCoordinates),
    ];
    if (points.isEmpty) return;

    // Keep a stable order: day -> start time -> fallback to API order.
    final entries = points.asMap().entries.toList(growable: false);
    entries.sort((a, b) {
      final ad = a.value.dayNumber;
      final bd = b.value.dayNumber;
      final dayCmp = ad.compareTo(bd);
      if (dayCmp != 0) return dayCmp;
      final am = a.value.startMinutes;
      final bm = b.value.startMinutes;
      final ax = am ?? (1 << 30);
      final bx = bm ?? (1 << 30);
      final cmp = ax.compareTo(bx);
      if (cmp != 0) return cmp;
      return a.key.compareTo(b.key);
    });

    final waypoints = <Position>[];

    final me = _myPosition;
    if (me != null) {
      waypoints.add(Position(me.longitude, me.latitude));
    }

    for (final e in entries) {
      final a = e.value;
      if (a.latitude == null || a.longitude == null) continue;
      waypoints.add(Position(a.longitude!, a.latitude!));
    }

    if (waypoints.length < 2) return;

    final routeKey =
        'driving|${waypoints.map((p) => '${p.lng.toStringAsFixed(6)},${p.lat.toStringAsFixed(6)}').join(';')}';
    if (routeKey == _lastRouteKey) {
      return;
    }
    _lastRouteKey = routeKey;

    final reqId = ++_routeRequestId;

    Future<void> drawStraightLine() async {
      if (reqId != _routeRequestId) return;
      try {
        await manager.deleteAll();
      } catch (_) {
        // Ignore.
      }
      try {
        await manager.create(
          PolylineAnnotationOptions(
            geometry: LineString(coordinates: waypoints),
            lineColor: AppColors.blue.withValues(alpha: 0.85).toARGB32(),
            lineWidth: 4.0,
            lineOpacity: 0.9,
          ),
        );
      } catch (_) {
        // Best-effort.
      }
    }

    try {
      final token = await _getMapboxAccessToken();
      if (token.isEmpty) {
        await drawStraightLine();
        return;
      }

      // Mapbox Directions API allows up to 25 coordinates per request.
      final positions = await _fetchDirectionsRoute(
        token: token,
        waypoints: waypoints,
        requestId: reqId,
      );
      if (positions.length < 2) {
        await drawStraightLine();
        return;
      }

      if (reqId != _routeRequestId) return;
      try {
        await manager.deleteAll();
      } catch (_) {
        // Ignore.
      }

      await manager.create(
        PolylineAnnotationOptions(
          geometry: LineString(coordinates: positions),
          lineColor: AppColors.blue.withValues(alpha: 0.92).toARGB32(),
          lineWidth: 4.5,
          lineOpacity: 0.95,
        ),
      );
    } catch (_) {
      await drawStraightLine();
    }
  }

  Future<String> _getMapboxAccessToken() async {
    if (_isMapboxSupportedPlatform) {
      try {
        final token = await MapboxOptions.getAccessToken();
        if (token.trim().isNotEmpty) return token.trim();
      } catch (_) {
        // Fallback to bundled token.
      }
    }
    return mapboxAccessToken;
  }

  Future<List<Position>> _fetchDirectionsRoute({
    required String token,
    required List<Position> waypoints,
    required int requestId,
  }) async {
    // If too many points, route each segment and concatenate.
    const int maxCoordsPerRequest = 25;
    if (waypoints.length <= maxCoordsPerRequest) {
      return _fetchDirectionsRouteSingle(
        token: token,
        coords: waypoints,
        requestId: requestId,
      );
    }

    final out = <Position>[];
    for (var i = 0; i < waypoints.length - 1; i++) {
      if (requestId != _routeRequestId) return const <Position>[];
      final seg = await _fetchDirectionsRouteSingle(
        token: token,
        coords: <Position>[waypoints[i], waypoints[i + 1]],
        requestId: requestId,
      );
      if (seg.isEmpty) continue;

      if (out.isEmpty) {
        out.addAll(seg);
      } else {
        // Avoid duplicating the shared point.
        out.addAll(seg.skip(1));
      }
    }
    return out;
  }

  Future<List<Position>> _fetchDirectionsRouteSingle({
    required String token,
    required List<Position> coords,
    required int requestId,
  }) async {
    if (coords.length < 2) return const <Position>[];
    if (requestId != _routeRequestId) return const <Position>[];

    final coordStr = coords.map((p) => '${p.lng},${p.lat}').join(';');
    final uri = Uri.parse(
      'https://api.mapbox.com/directions/v5/mapbox/driving/$coordStr'
      '?alternatives=false&geometries=geojson&overview=full&steps=false'
      '&access_token=$token'
      '&language=vi',
    );

    final res = await http.get(uri);
    if (requestId != _routeRequestId) return const <Position>[];
    if (res.statusCode < 200 || res.statusCode >= 300) {
      return const <Position>[];
    }

    final json = jsonDecode(res.body);
    if (json is! Map) return const <Position>[];
    final routes = (json['routes'] as List?) ?? const [];
    if (routes.isEmpty) return const <Position>[];
    final r0 = routes.first;
    if (r0 is! Map) return const <Position>[];
    final geometry = (r0['geometry'] as Map?)?.cast<String, dynamic>();
    final coordsRaw = (geometry?['coordinates'] as List?) ?? const [];

    final positions = <Position>[];
    for (final c in coordsRaw) {
      if (c is List && c.length >= 2) {
        final lng = (c[0] as num).toDouble();
        final lat = (c[1] as num).toDouble();
        positions.add(Position(lng, lat));
      }
    }
    return positions;
  }

  Future<void> _maybeFitCameraToActivities(_DayActivities activities) async {
    if (!_isMapboxSupportedPlatform) return;
    if (_didInitialFit) return;

    final map = _map;
    if (map == null) return;

    _ActivityItem? first;
    for (final a in activities.confirmed) {
      if (a.hasCoordinates) {
        first = a;
        break;
      }
    }
    if (first == null) {
      for (final a in activities.proposed) {
        if (a.hasCoordinates) {
          first = a;
          break;
        }
      }
    }

    if (first == null || first.latitude == null || first.longitude == null) {
      final me = _myPosition;
      if (me == null) return;
      _didInitialFit = true;
      try {
        await map.setCamera(
          CameraOptions(
            center: Point(coordinates: Position(me.longitude, me.latitude)),
            zoom: 12.5,
          ),
        );
      } catch (_) {
        // Best-effort.
      }
      return;
    }

    _didInitialFit = true;
    try {
      await map.setCamera(
        CameraOptions(
          center: Point(
            coordinates: Position(first.longitude!, first.latitude!),
          ),
          zoom: 11.5,
        ),
      );
    } catch (_) {
      // Best-effort.
    }
  }

  Future<void> _syncMarkers(_DayActivities activities) async {
    if (!_isMapboxSupportedPlatform) return;
    final confirmedManager = _confirmedManager;
    final proposedManager = _proposedManager;
    if (confirmedManager == null || proposedManager == null) return;

    await _ensureMarkerFallbacks();

    try {
      await confirmedManager.deleteAll();
    } catch (_) {
      // Ignore.
    }
    try {
      await proposedManager.deleteAll();
    } catch (_) {
      // Ignore.
    }

    final confirmed = activities.confirmed
        .where((a) => a.hasCoordinates)
        .toList(growable: false);
    final proposed = activities.proposed
        .where((a) => a.hasCoordinates)
        .toList(growable: false);

    // Build missing (category + time) marker images (cached).
    final confirmedKeys = <String>{
      for (final a in confirmed) _markerKeyForActivity(a),
    };
    final proposedKeys = <String>{
      for (final a in proposed) _markerKeyForActivity(a),
    };

    for (final key in confirmedKeys) {
      if (_confirmedMarkerByKey.containsKey(key)) continue;
      final parts = key.split('|');
      final cat = parts.isNotEmpty ? parts.first : '';
      final timeLabel = parts.length >= 2 ? parts[1] : '';
      final icon = _markerIconForCategory(cat);
      _confirmedMarkerByKey[key] = await _buildIconImage(
        icon: icon,
        color: AppColors.primary,
        label: timeLabel,
      );
    }

    for (final key in proposedKeys) {
      if (_proposedMarkerByKey.containsKey(key)) continue;
      final parts = key.split('|');
      final cat = parts.isNotEmpty ? parts.first : '';
      final timeLabel = parts.length >= 2 ? parts[1] : '';
      final icon = _markerIconForCategory(cat);
      _proposedMarkerByKey[key] = await _buildIconImage(
        icon: icon,
        color: AppColors.accent,
        label: timeLabel,
      );
    }

    final confirmedOptions = <PointAnnotationOptions>[];
    for (final a in confirmed) {
      final key = _markerKeyForActivity(a);
      final bytes = _confirmedMarkerByKey[key] ?? _confirmedMarkerFallback;
      if (bytes == null) continue;
      confirmedOptions.add(
        PointAnnotationOptions(
          geometry: Point(coordinates: Position(a.longitude!, a.latitude!)),
          image: bytes,
          iconSize: 1.7,
          iconHaloColor: 0xFFFFFFFF,
          iconHaloWidth: 2.0,
          iconHaloBlur: 0.5,
        ),
      );
    }

    final proposedOptions = <PointAnnotationOptions>[];
    for (final a in proposed) {
      final key = _markerKeyForActivity(a);
      final bytes = _proposedMarkerByKey[key] ?? _proposedMarkerFallback;
      if (bytes == null) continue;
      proposedOptions.add(
        PointAnnotationOptions(
          geometry: Point(coordinates: Position(a.longitude!, a.latitude!)),
          image: bytes,
          iconSize: 1.7,
          iconHaloColor: 0xFFFFFFFF,
          iconHaloWidth: 2.0,
          iconHaloBlur: 0.5,
        ),
      );
    }

    try {
      if (confirmedOptions.isNotEmpty) {
        await confirmedManager.createMulti(confirmedOptions);
      }
    } catch (_) {
      // Best-effort.
    }

    try {
      if (proposedOptions.isNotEmpty) {
        await proposedManager.createMulti(proposedOptions);
      }
    } catch (_) {
      // Best-effort.
    }
  }

  Future<void> _zoomBy(double delta) async {
    final map = _map;
    if (map == null) return;

    try {
      final camera = await map.getCameraState();
      final currentZoom = camera.zoom;
      final nextZoom = (currentZoom + delta).clamp(0.0, 22.0);
      await map.setCamera(CameraOptions(zoom: nextZoom));
    } catch (_) {
      // Best-effort.
    }
  }

  Future<_DayActivities> _loadActivitiesForTripAllDays() async {
    final tripId = trip.id;
    if (tripId == null) return const _DayActivities.empty();

    final days = trip.daysCount;
    if (days <= 0) return const _DayActivities.empty();

    try {
      final perDay = await Future.wait(
        List<Future<_DayActivities>>.generate(
          days,
          (i) => _loadActivitiesForDay(dayNumber: i + 1),
          growable: false,
        ),
      );

      final confirmed = <_ActivityItem>[];
      final proposed = <_ActivityItem>[];
      for (final d in perDay) {
        confirmed.addAll(d.confirmed);
        proposed.addAll(d.proposed);
      }
      return _DayActivities(confirmed: confirmed, proposed: proposed);
    } catch (_) {
      return const _DayActivities.empty();
    }
  }

  Future<_DayActivities> _loadActivitiesForDay({required int dayNumber}) async {
    final tripId = trip.id;
    if (tripId == null) return const _DayActivities.empty();

    final res = await _apiClient.get<dynamic>(
      ApiEndpoints.itineraryActivitiesByDay(
        tripId: tripId,
        dayNumber: dayNumber,
      ),
    );

    final raw = res.data;
    if (raw is! Map) return const _DayActivities.empty();

    final data = raw['data'];
    final payload = _extractActivitiesPayload(data);

    final confirmed = <_ActivityItem>[];
    final proposed = <_ActivityItem>[];

    for (final item in payload.items) {
      final a = _ActivityItem.fromJson(item, dayNumber: dayNumber);
      if (a == null) continue;
      (a.isConfirmed ? confirmed : proposed).add(a);
    }

    for (final item in payload.confirmed) {
      final a = _ActivityItem.fromJson(
        item,
        dayNumber: dayNumber,
        forceConfirmed: true,
      );
      if (a != null) confirmed.add(a);
    }

    for (final item in payload.proposed) {
      final a = _ActivityItem.fromJson(
        item,
        dayNumber: dayNumber,
        forceConfirmed: false,
      );
      if (a != null) proposed.add(a);
    }

    return _DayActivities(confirmed: confirmed, proposed: proposed);
  }

  _ActivitiesPayload _extractActivitiesPayload(dynamic data) {
    if (data is List) {
      return _ActivitiesPayload(items: data);
    }

    if (data is Map) {
      final confirmed = data['confirmed'];
      final proposed = data['proposed'];
      if (confirmed is List || proposed is List) {
        return _ActivitiesPayload(
          items: const [],
          confirmed: (confirmed is List) ? confirmed : const [],
          proposed: (proposed is List) ? proposed : const [],
        );
      }

      final activities =
          data['activities'] ??
          data['items'] ??
          data['results'] ??
          data['data'];
      if (activities is List) {
        return _ActivitiesPayload(items: activities);
      }
    }

    return const _ActivitiesPayload(items: []);
  }

  Future<Uint8List?> _buildIconImage({
    required IconData icon,
    required Color color,
    String? label,
  }) async {
    try {
      const double size = 84;
      const double labelHeight = 22;
      final normalizedLabel = (label ?? '').trim();
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // Optional time label at the bottom.
      if (normalizedLabel.isNotEmpty) {
        final labelPainter = TextPainter(
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          text: TextSpan(
            text: normalizedLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFamily: 'Poppins',
            ),
          ),
        )..layout();

        final padX = 8.0;
        final padY = 3.0;
        final pillW = (labelPainter.width + padX * 2).clamp(34.0, size - 6.0);
        final pillH = (labelPainter.height + padY * 2).clamp(16.0, labelHeight);
        final pillLeft = (size - pillW) / 2;
        final pillTop = size - pillH - 2.0;

        final rrect = RRect.fromRectAndRadius(
          Rect.fromLTWH(pillLeft, pillTop, pillW, pillH),
          const Radius.circular(10),
        );
        final paint = Paint()..color = Colors.white.withValues(alpha: 0.98);
        canvas.drawRRect(rrect, paint);

        // Subtle border.
        final border = Paint()
          ..color = AppColors.divider.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawRRect(rrect, border);

        final tx = (size - labelPainter.width) / 2;
        final ty = pillTop + (pillH - labelPainter.height) / 2;
        labelPainter.paint(canvas, Offset(tx, ty));
      }

      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            fontSize: 58,
            color: color,
          ),
        ),
      )..layout();

      final iconBottomReserve = normalizedLabel.isNotEmpty ? labelHeight : 0.0;
      final dy = ((size - iconBottomReserve) - textPainter.height) / 2;
      final dx = (size - textPainter.width) / 2;
      textPainter.paint(canvas, Offset(dx, dy));

      final picture = recorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final bytes = await image.toByteData(format: ImageByteFormat.png);
      return bytes?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }
}

class _DayActivities {
  final List<_ActivityItem> confirmed;
  final List<_ActivityItem> proposed;

  const _DayActivities({required this.confirmed, required this.proposed});

  const _DayActivities.empty() : confirmed = const [], proposed = const [];
}

class _ActivitiesPayload {
  final List<dynamic> items;
  final List<dynamic> confirmed;
  final List<dynamic> proposed;

  const _ActivitiesPayload({
    required this.items,
    this.confirmed = const [],
    this.proposed = const [],
  });
}

class _ActivityItem {
  final bool isConfirmed;
  final int dayNumber;
  final String title;
  final String category;
  final String subtitle;
  final String proposedBy;
  final double? latitude;
  final double? longitude;
  final int? startMinutes;

  const _ActivityItem({
    required this.isConfirmed,
    required this.dayNumber,
    required this.title,
    required this.category,
    required this.subtitle,
    required this.proposedBy,
    required this.latitude,
    required this.longitude,
    required this.startMinutes,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  static _ActivityItem? fromJson(
    dynamic raw, {
    bool? forceConfirmed,
    int dayNumber = 1,
  }) {
    if (raw is! Map) return null;
    final wrapper = Map<String, dynamic>.from(raw);
    final nestedActivityRaw = wrapper['activity'] ?? wrapper['Activity'];
    final nested = (nestedActivityRaw is Map)
        ? Map<String, dynamic>.from(nestedActivityRaw)
        : null;

    dynamic pickValue(String key) {
      final v = nested != null ? nested[key] : null;
      if (v != null) return v;
      return wrapper[key];
    }

    bool pickBool(List<String> keys) {
      for (final k in keys) {
        final v = pickValue(k);
        if (v == null) continue;
        if (v is bool) return v;
        final s = v.toString().toLowerCase();
        if (s == 'true') return true;
        if (s == 'false') return false;
      }
      return false;
    }

    String pickString(List<String> keys) {
      for (final k in keys) {
        final v = pickValue(k);
        if (v == null) continue;
        final s = v.toString().trim();
        if (s.isNotEmpty) return s;
      }
      return '';
    }

    String pickNestedName(dynamic raw) {
      if (raw is! Map) return '';
      final mm = Map<String, dynamic>.from(raw);
      return (mm['name'] ?? mm['full_name'] ?? mm['email'] ?? '').toString();
    }

    double? pickDouble(List<String> keys) {
      for (final k in keys) {
        final v = pickValue(k);
        if (v == null) continue;
        if (v is num) return v.toDouble();
        final parsed = double.tryParse(v.toString());
        if (parsed != null) return parsed;
      }
      return null;
    }

    int? parseTimeMinutes(String raw) {
      final s = raw.trim();
      if (s.isEmpty) return null;
      final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(s);
      if (match == null) return null;
      final hh = int.tryParse(match.group(1) ?? '');
      final mm = int.tryParse(match.group(2) ?? '');
      if (hh == null || mm == null) return null;
      return hh * 60 + mm;
    }

    final status = pickString(['status', 'state']).toLowerCase();
    final isConfirmed =
        forceConfirmed ??
        pickBool(['is_confirmed', 'confirmed', 'isConfirmed']) ||
            status == 'confirmed';

    final title = pickString(['title', 'name']);
    final category = pickString(['category', 'type', 'activity_type']);
    final description = pickString(['subtitle', 'description', 'note']);
    // Popup subtitle should be the human description if present.
    final subtitle = description.isNotEmpty ? description : category;

    final createdBy =
        pickValue('created_by') ??
        pickValue('createdBy') ??
        pickValue('creator');
    final proposedBy = (pickNestedName(createdBy).trim().isNotEmpty)
        ? pickNestedName(createdBy).trim()
        : pickString(['created_by_name', 'createdByName', 'proposed_by']);

    // Best-effort: support multiple possible backend keys.
    final latitude = pickDouble([
      'lat',
      'latitude',
      'location_lat',
      'location_latitude',
      'locationLatitude',
    ]);
    final longitude = pickDouble([
      'lng',
      'lon',
      'longitude',
      'location_lng',
      'location_long',
      'location_lon',
      'location_longitude',
      'locationLongitude',
    ]);

    final startTimeText = pickString(['start_time', 'startTime', 'time']);
    final startMinutes = parseTimeMinutes(startTimeText);

    return _ActivityItem(
      isConfirmed: isConfirmed,
      dayNumber: dayNumber,
      title: title.isEmpty ? 'Hoạt động' : title,
      category: category,
      subtitle: subtitle,
      proposedBy: proposedBy,
      latitude: latitude,
      longitude: longitude,
      startMinutes: startMinutes,
    );
  }
}
