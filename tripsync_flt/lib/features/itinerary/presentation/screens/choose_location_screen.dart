import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../models/picked_location.dart';
import '../../../../core/config/mapbox.dart';

part '../widgets/choose_location_screen_widgets.dart';

class ChooseLocationScreen extends StatefulWidget {
  const ChooseLocationScreen({super.key});

  @override
  State<ChooseLocationScreen> createState() => _ChooseLocationScreenState();
}

class _ChooseLocationScreenState extends State<ChooseLocationScreen> {
  MapboxMap? _map;
  PointAnnotationManager? _pointAnnotationManager;
  CircleAnnotationManager? _circleAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;
  Uint8List? _pinImage;
  PickedLocation? _selected;
  bool _isResolving = false;
  int _geocodeRequestId = 0;

  geo.Position? _myPosition;
  bool _routeLoading = false;
  String? _routeError;
  double? _routeDistanceMeters;
  int _routeRequestId = 0;

  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _searchDebounce;
  bool _searchLoading = false;
  String? _searchError;
  List<_PlaceResult> _searchResults = const [];
  late String _searchSessionToken;

  static const double _defaultLat = 21.0278;
  static const double _defaultLng = 105.8342;

  static const Color _pinGreen = Color(0xFF00D26A);
  // static const Color _myLocationDot = Color(0xFF00D26A);

  static bool get _isMapboxSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    _searchSessionToken = _newSessionToken();
    _searchFocus.addListener(() {
      if (!mounted) return;
      setState(() {
        // Rebuild to show/hide the suggestion overlay.
      });
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  static String _newSessionToken() {
    final rand = Random();
    final a = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    // On web, `1 << 32` becomes 0 (JS bitwise ops are 32-bit), which would
    // crash with `nextInt(0)`. Use a safe positive max instead.
    const max = 0x7fffffff; // < 2^32 and safe across platforms
    final b = rand.nextInt(max).toRadixString(16).padLeft(8, '0');
    final c = rand.nextInt(max).toRadixString(16).padLeft(8, '0');
    return '$a-$b-$c';
  }

  @override
  Widget build(BuildContext context) {
    final selection = _selected;
    final title = selection == null
        ? (_isResolving ? 'Đang lấy địa chỉ...' : 'Chọn vị trí trên bản đồ')
        : ((selection.placeName?.isNotEmpty ?? false)
              ? selection.placeName!
              : ((selection.address?.isNotEmpty ?? false)
                    ? selection.address!
                    : (_isResolving
                          ? 'Đang lấy địa chỉ...'
                          : selection.label)));
    final address = selection == null
        ? (_isResolving
              ? 'Vui lòng đợi một chút'
              : 'Chạm vào bản đồ để chọn tọa độ')
        : ((selection.address?.isNotEmpty ?? false)
              ? selection.address!
              : 'Tọa độ: ${selection.latitude.toStringAsFixed(6)}, ${selection.longitude.toStringAsFixed(6)}');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: _isMapboxSupportedPlatform
                ? MapWidget(
                    styleUri: MapboxStyles.STANDARD,
                    cameraOptions: CameraOptions(
                      center: Point(
                        coordinates: Position(_defaultLng, _defaultLat),
                      ),
                      zoom: 12,
                    ),
                    onMapCreated: (mapboxMap) {
                      _map = mapboxMap;
                      _initMarkerSupport();
                    },
                    onTapListener: _handleMapTap,
                  )
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _searchFocus.unfocus(),
                    child: const ColoredBox(color: Color(0xFFE5E7EB)),
                  ),
          ),
          _Header(onBack: () => Navigator.of(context).pop()),
          _SearchBar(
            controller: _searchCtrl,
            focusNode: _searchFocus,
            onChanged: _onSearchChanged,
          ),
          if (_selected != null && !_isMapboxSupportedPlatform)
            const _SelectedPinOverlay(),
          _BottomSheet(
            title: title,
            address: address,
            distanceText: _routeDistanceMeters != null
                ? _formatDistance(_routeDistanceMeters!)
                : null,
            routeError: _routeError,
            routeLoading: _routeLoading,
            onMyLocation: _useMyLocation,
            onRoute: (_selected != null && !_isResolving) ? _buildRoute : null,
            onConfirm: (_selected != null && !_isResolving)
                ? _confirmSelection
                : null,
          ),
          // Keep search results on top so they are not covered by the bottom sheet.
          if (_shouldShowSearchOverlay)
            _SearchResultsOverlay(
              loading: _searchLoading,
              error: _searchError,
              results: _searchResults,
              onSelect: _selectSearchResult,
            ),
        ],
      ),
    );
  }

  bool get _shouldShowSearchOverlay {
    final q = _searchCtrl.text.trim();
    if (!_searchFocus.hasFocus) return false;
    if (q.isEmpty) return false;
    // Show if we have anything to communicate.
    if (_searchLoading) return true;
    if (_searchError != null) return true;
    return _searchResults.isNotEmpty;
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _search(value.trim());
    });
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        _searchLoading = false;
        _searchError = null;
        _searchResults = const [];
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _searchLoading = true;
      _searchError = null;
    });

    try {
      final token = await _getMapboxAccessToken();
      if (token.isEmpty) throw Exception('Missing Mapbox access token');

      final proximity = _selected != null
          ? Position(_selected!.longitude, _selected!.latitude)
          : Position(_defaultLng, _defaultLat);

      final parsed = await _searchBoxSuggest(
        token: token,
        query: query,
        proximity: proximity,
        sessionToken: _searchSessionToken,
      );

      if (!mounted) return;
      setState(() {
        _searchResults = parsed;
        _searchLoading = false;
        _searchError = parsed.isEmpty ? 'Không tìm thấy kết quả.' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchLoading = false;
        _searchError = e.toString();
        _searchResults = const [];
      });
    }
  }

  Future<void> _selectSearchResult(_PlaceResult r) async {
    final token = await _getMapboxAccessToken();
    if (token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _searchError = 'Thiếu Mapbox access token.';
      });
      return;
    }

    final mapboxId = r.mapboxId;
    if (mapboxId == null || mapboxId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _searchError = 'Không thể lấy tọa độ cho kết quả này.';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _searchLoading = true;
      _searchError = null;
    });

    try {
      final retrieved = await _searchBoxRetrieve(
        token: token,
        mapboxId: mapboxId,
        sessionToken: _searchSessionToken,
      );

      if (!mounted) return;
      setState(() => _searchLoading = false);

      if (retrieved == null) {
        setState(() {
          _searchError = 'Không thể lấy chi tiết địa điểm.';
        });
        return;
      }

      final lat = retrieved.lat;
      final lng = retrieved.lng;

      _map?.setCamera(
        CameraOptions(center: Point(coordinates: Position(lng, lat)), zoom: 14),
      );

      setState(() {
        _clearRoute();
        _selected = PickedLocation(
          label: retrieved.label,
          latitude: lat,
          longitude: lng,
          placeName: retrieved.placeName,
          address: retrieved.address,
        );
        _isResolving = false;

        // Hide overlay after selection.
        _searchResults = const [];
        _searchError = null;
      });

      _searchCtrl.text = retrieved.placeName?.isNotEmpty == true
          ? retrieved.placeName!
          : retrieved.label;
      _searchCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchCtrl.text.length),
      );
      _searchFocus.unfocus();

      await _updateMarker(lat: lat, lng: lng);

      if ((retrieved.address ?? '').isEmpty &&
          (retrieved.placeName ?? '').isEmpty) {
        _reverseGeocode(lat: lat, lng: lng);
      }

      // New session for next search interaction.
      _searchSessionToken = _newSessionToken();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchLoading = false;
        _searchError = e.toString();
      });
    }
  }

  String? _readHttpError(http.Response res) {
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        final message = (decoded['message'] as String?)?.trim();
        if (message != null && message.isNotEmpty) return message;
        final error = (decoded['error'] as String?)?.trim();
        if (error != null && error.isNotEmpty) return error;
      }
    } catch (_) {
      // Ignore.
    }
    return null;
  }

  Future<List<_PlaceResult>> _searchBoxSuggest({
    required String token,
    required String query,
    required Position proximity,
    required String sessionToken,
  }) async {
    final uri = Uri.parse(
      'https://api.mapbox.com/search/searchbox/v1/suggest'
      '?q=${Uri.encodeComponent(query)}'
      '&access_token=$token'
      '&language=vi'
      '&limit=10'
      '&proximity=${proximity.lng},${proximity.lat}'
      '&session_token=$sessionToken'
      '&types=poi,address,place,locality,neighborhood,region,country',
    );

    final res = await http.get(uri);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        _readHttpError(res) ?? 'Search failed (${res.statusCode})',
      );
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final suggestions = (json['suggestions'] as List? ?? const []);

    return suggestions.map((s) {
      final m = s as Map<String, dynamic>;
      final name = m['name'] as String?;
      final fullAddress = m['full_address'] as String?;
      final placeFormatted = m['place_formatted'] as String?;
      return _PlaceResult(
        label: name ?? fullAddress ?? placeFormatted ?? 'Unknown',
        placeName: name,
        address: fullAddress ?? placeFormatted,
        lat: 0,
        lng: 0,
        mapboxId: (m['mapbox_id'] as String?),
      );
    }).toList();
  }

  Future<_PlaceResult?> _searchBoxRetrieve({
    required String token,
    required String mapboxId,
    required String sessionToken,
  }) async {
    final uri = Uri.parse(
      'https://api.mapbox.com/search/searchbox/v1/retrieve/$mapboxId'
      '?access_token=$token'
      '&session_token=$sessionToken',
    );

    final res = await http.get(uri);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        _readHttpError(res) ?? 'Retrieve failed (${res.statusCode})',
      );
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final feats = (json['features'] as List? ?? const []);
    if (feats.isEmpty) return null;

    final f = feats.first as Map<String, dynamic>;
    final coords =
        (((f['geometry'] as Map)['coordinates']) as List?) ?? const [];
    if (coords.length < 2) return null;
    final lng = (coords[0] as num).toDouble();
    final lat = (coords[1] as num).toDouble();

    final props = (f['properties'] as Map?)?.cast<String, dynamic>() ?? {};
    final name = (props['name'] as String?)?.trim();
    final fullAddress = (props['full_address'] as String?)?.trim();
    final placeFormatted = (props['place_formatted'] as String?)?.trim();
    return _PlaceResult(
      label: name ?? fullAddress ?? placeFormatted ?? '$lat,$lng',
      placeName: name,
      address: fullAddress ?? placeFormatted,
      lat: lat,
      lng: lng,
      mapboxId: mapboxId,
    );
  }

  Future<void> _initMarkerSupport() async {
    if (!_isMapboxSupportedPlatform) return;
    final map = _map;
    if (map == null) return;

    _pointAnnotationManager ??= await map.annotations
        .createPointAnnotationManager();

    _circleAnnotationManager ??= await map.annotations
        .createCircleAnnotationManager();

    _polylineAnnotationManager ??= await map.annotations
        .createPolylineAnnotationManager();

    _pinImage ??= await _buildGreenPinImage();

    // If we already have a selection (e.g., from search), show it on the map.
    final selected = _selected;
    if (selected != null) {
      await _updateMarker(lat: selected.latitude, lng: selected.longitude);
    }

    // If we already resolved my location, show it too.
    final myPos = _myPosition;
    if (myPos != null) {
      await _updateMyLocationMarker(
        lat: myPos.latitude,
        lng: myPos.longitude,
        accuracyMeters: myPos.accuracy,
      );
    }
  }

  Future<void> _updateMyLocationMarker({
    required double lat,
    required double lng,
    double? accuracyMeters,
  }) async {
    if (!_isMapboxSupportedPlatform) return;
    final manager = _circleAnnotationManager;
    if (manager == null) return;

    // Recreate markers to keep state simple.
    try {
      await manager.deleteAll();
    } catch (_) {
      // Ignore.
    }

    final point = Point(coordinates: Position(lng, lat));

    // Simple accuracy halo (pixel radius derived from accuracy meters).
    double haloRadiusPx = 40;
    final acc = accuracyMeters ?? 0;
    if (acc > 0) {
      // Rough heuristic: scale meters to pixels; keeps halo visible across zoom levels.
      // Not a true projection, but good enough for a lightweight UX hint.
      haloRadiusPx = (acc * 0.6).clamp(24, 120).toDouble();
    }

    final halo = CircleAnnotationOptions(
      geometry: point,
      circleColor: 0xFF00D26A,
      circleOpacity: 0.18,
      circleRadius: haloRadiusPx,
      circleBlur: 0.2,
    );

    final dot = CircleAnnotationOptions(
      geometry: point,
      circleColor: 0xFF00D26A,
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

  Future<Uint8List?> _buildGreenPinImage() async {
    try {
      // Build a green pin using the same Material icon used elsewhere in the UI.
      const double size = 72;
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(
          text: String.fromCharCode(Icons.place.codePoint),
          style: TextStyle(
            fontFamily: Icons.place.fontFamily,
            package: Icons.place.fontPackage,
            fontSize: 64,
            color: _pinGreen,
          ),
        ),
      )..layout();

      // Center the glyph within the image.
      final dx = (size - textPainter.width) / 2;
      final dy = (size - textPainter.height) / 2;
      textPainter.paint(canvas, Offset(dx, dy));

      final picture = recorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final bytes = await image.toByteData(format: ImageByteFormat.png);
      return bytes?.buffer.asUint8List();
    } catch (_) {
      // Best-effort; if this fails, Mapbox can still render a default marker.
      return null;
    }
  }

  Future<void> _updateMarker({required double lat, required double lng}) async {
    final manager = _pointAnnotationManager;
    if (manager == null) return;

    try {
      await manager.deleteAll();
    } catch (_) {
      // Ignore; we will still attempt to create a marker.
    }

    final options = PointAnnotationOptions(
      geometry: Point(coordinates: Position(lng, lat)),
      image: _pinImage,
      // Make the pin easier to see.
      iconSize: 2.2,
      iconHaloColor: 0xFFFFFFFF,
      iconHaloWidth: 2.0,
      iconHaloBlur: 0.5,
    );
    try {
      await manager.create(options);
    } catch (_) {
      // Best-effort; marker is a UX enhancement.
    }
  }

  void _handleMapTap(MapContentGestureContext context) {
    // If the user taps on the map, dismiss the inline search dropdown.
    if (_searchFocus.hasFocus) _searchFocus.unfocus();

    final pos = context.point.coordinates;
    final lng = pos.lng.toDouble();
    final lat = pos.lat.toDouble();

    _clearRoute();

    // Move camera so the pinned center still represents selection.
    _map?.setCamera(
      CameraOptions(center: Point(coordinates: Position(lng, lat))),
    );

    _updateMarker(lat: lat, lng: lng);

    // Immediately store coordinate; label/address resolved async.
    setState(() {
      _selected = PickedLocation(
        label: '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
        latitude: lat,
        longitude: lng,
      );
      _isResolving = true;
    });

    _reverseGeocode(lat: lat, lng: lng);
  }

  Future<void> _reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    final requestId = ++_geocodeRequestId;

    try {
      final token = await _getMapboxAccessToken();
      if (token.isEmpty) {
        throw Exception('Missing Mapbox access token');
      }

      // Pass 1: POI-only reverse to increase the chance we get a restaurant/cafe
      // name when tapping near it.
      final poiOnly = await _searchBoxReverse(
        token: token,
        lat: lat,
        lng: lng,
        requestId: requestId,
        types: 'poi',
        limit: 10,
      );

      // Pass 2: fallback to a broader reverse if there is no POI.
      final result =
          poiOnly ??
          await _searchBoxReverse(
            token: token,
            lat: lat,
            lng: lng,
            requestId: requestId,
            types: 'poi,address,place,locality,neighborhood,region,country',
            limit: 10,
          );
      final placeName = result?.placeName?.trim();
      final fullAddress = result?.address?.trim();

      if (!mounted || requestId != _geocodeRequestId) return;

      setState(() {
        final current = _selected;
        if (current == null) return;
        final label = (placeName?.isNotEmpty == true)
            ? placeName!
            : ((fullAddress?.isNotEmpty == true)
                  ? fullAddress!
                  : current.label);

        _selected = PickedLocation(
          label: label,
          latitude: current.latitude,
          longitude: current.longitude,
          placeName: placeName,
          address: fullAddress,
        );
        _isResolving = false;
      });
    } catch (_) {
      if (!mounted || requestId != _geocodeRequestId) return;
      setState(() {
        _isResolving = false;
      });
    }
  }

  Future<_PlaceResult?> _searchBoxReverse({
    required String token,
    required double lat,
    required double lng,
    required int requestId,
    required String types,
    required int limit,
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.mapbox.com/search/searchbox/v1/reverse'
        '?longitude=$lng&latitude=$lat'
        '&access_token=$token'
        '&language=vi&limit=$limit'
        '&types=$types',
      );

      final res = await http.get(uri);
      if (res.statusCode < 200 || res.statusCode >= 300) return null;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final feats = (json['features'] as List?) ?? const [];
      if (feats.isEmpty) return null;

      final picked = _pickBestSearchBoxReverseFeature(feats);
      final props =
          (picked['properties'] as Map?)?.cast<String, dynamic>() ?? {};

      final featureType = (props['feature_type'] as String?)?.trim();
      final name = (props['name'] as String?)?.trim();
      final placeFormatted = (props['place_formatted'] as String?)?.trim();
      final fullAddress = (props['full_address'] as String?)?.trim();

      // Avoid showing street names as the main label. If reverse resolves to a
      // street-like feature, use the broader formatted place instead.
      final looksLikeStreet =
          (featureType == 'street') ||
          (name?.startsWith('Phố ') == true) ||
          (name?.startsWith('Đường ') == true);

      final safeLabel = (!looksLikeStreet && name?.isNotEmpty == true)
          ? name!
          : ((placeFormatted?.isNotEmpty == true)
                ? placeFormatted!
                : ((fullAddress?.isNotEmpty == true)
                      ? fullAddress!
                      : '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}'));

      final safeAddress = (fullAddress?.isNotEmpty == true)
          ? fullAddress
          : (placeFormatted?.isNotEmpty == true ? placeFormatted : null);

      if (!mounted || requestId != _geocodeRequestId) return null;

      return _PlaceResult(
        label: safeLabel,
        placeName: (!looksLikeStreet && name?.isNotEmpty == true) ? name : null,
        address: safeAddress,
        lat: lat,
        lng: lng,
      );
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _pickBestSearchBoxReverseFeature(List feats) {
    // Prefer POI (restaurant/cafe) first.
    for (final item in feats) {
      final f = item as Map<String, dynamic>;
      final props = (f['properties'] as Map?)?.cast<String, dynamic>() ?? {};
      final featureType = (props['feature_type'] as String?)?.trim();
      if (featureType == 'poi') return f;
    }

    // Otherwise prefer address.
    for (final item in feats) {
      final f = item as Map<String, dynamic>;
      final props = (f['properties'] as Map?)?.cast<String, dynamic>() ?? {};
      final featureType = (props['feature_type'] as String?)?.trim();
      if (featureType == 'address') return f;
    }

    // Otherwise take the first result.
    return feats.first as Map<String, dynamic>;
  }

  void _confirmSelection() {
    final selected = _selected;
    if (selected == null) return;
    Navigator.of(context).pop<PickedLocation>(selected);
  }

  Future<String> _getMapboxAccessToken() async {
    if (_isMapboxSupportedPlatform) {
      try {
        final token = await MapboxOptions.getAccessToken();
        if (token.isNotEmpty) return token;
      } catch (_) {
        // Fall back.
      }
    }
    return mapboxAccessToken;
  }

  // Search is handled inline (no bottom sheet).

  void _clearRoute() {
    _routeRequestId++;
    _routeError = null;
    _routeDistanceMeters = null;

    final manager = _polylineAnnotationManager;
    if (manager != null) {
      // Best-effort; route line is a UX enhancement.
      manager.deleteAll().catchError((_) {});
    }
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return 'Khoảng cách: ${meters.toStringAsFixed(0)} m';
    }
    final km = meters / 1000.0;
    return 'Khoảng cách: ${km.toStringAsFixed(1)} km';
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
    final pos = await _getCurrentPosition();
    if (pos == null) return;

    final lat = pos.latitude;
    final lng = pos.longitude;
    _myPosition = pos;

    _clearRoute();

    setState(() {
      _selected = PickedLocation(
        label: '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
        latitude: lat,
        longitude: lng,
      );
      _isResolving = true;
    });

    _map?.setCamera(
      CameraOptions(center: Point(coordinates: Position(lng, lat)), zoom: 14),
    );
    await _updateMarker(lat: lat, lng: lng);
    await _updateMyLocationMarker(
      lat: lat,
      lng: lng,
      accuracyMeters: pos.accuracy,
    );

    _reverseGeocode(lat: lat, lng: lng);
  }

  Future<void> _buildRoute() async {
    final selected = _selected;
    if (selected == null) return;

    final reqId = ++_routeRequestId;
    setState(() {
      _routeLoading = true;
      _routeError = null;
      _routeDistanceMeters = null;
    });

    final start = _myPosition ?? await _getCurrentPosition();
    if (start == null) {
      if (!mounted || reqId != _routeRequestId) return;
      setState(() {
        _routeLoading = false;
        _routeError = 'Không lấy được vị trí của bạn.';
      });
      return;
    }
    _myPosition = start;
    // Show my location dot if we have a map.
    await _updateMyLocationMarker(
      lat: start.latitude,
      lng: start.longitude,
      accuracyMeters: start.accuracy,
    );

    try {
      final token = await _getMapboxAccessToken();
      if (token.isEmpty) throw Exception('Missing Mapbox access token');

      final uri = Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/driving/'
        '${start.longitude},${start.latitude};'
        '${selected.longitude},${selected.latitude}'
        '?alternatives=false&geometries=geojson&overview=full&steps=false'
        '&access_token=$token'
        '&language=vi',
      );

      final res = await http.get(uri);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception(
          _readHttpError(res) ?? 'Route failed (${res.statusCode})',
        );
      }

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final routes = (json['routes'] as List?) ?? const [];
      if (routes.isEmpty) throw Exception('Không tìm thấy đường đi.');

      final r0 = routes.first as Map<String, dynamic>;
      final distance = (r0['distance'] as num?)?.toDouble();
      final geometry = (r0['geometry'] as Map?)?.cast<String, dynamic>();
      final coords = (geometry?['coordinates'] as List?) ?? const [];

      if (!mounted || reqId != _routeRequestId) return;

      setState(() {
        _routeLoading = false;
        _routeDistanceMeters = distance;
        _routeError = null;
      });

      // Draw polyline route if Mapbox map is supported.
      if (_isMapboxSupportedPlatform) {
        final manager = _polylineAnnotationManager;
        if (manager != null && coords.isNotEmpty) {
          try {
            await manager.deleteAll();
          } catch (_) {
            // Ignore.
          }

          final positions = <Position>[];
          for (final c in coords) {
            if (c is List && c.length >= 2) {
              final lng = (c[0] as num).toDouble();
              final lat = (c[1] as num).toDouble();
              positions.add(Position(lng, lat));
            }
          }
          if (positions.length >= 2) {
            await manager.create(
              PolylineAnnotationOptions(
                geometry: LineString(coordinates: positions),
                lineColor: 0xFF00D26A,
                lineWidth: 5.0,
                lineOpacity: 0.9,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (!mounted || reqId != _routeRequestId) return;
      setState(() {
        _routeLoading = false;
        _routeError = e.toString();
        _routeDistanceMeters = null;
      });
    }
  }
}
