import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'routes/app_routes.dart';
import 'core/config/mapbox.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // mapbox_maps_flutter is backed by native SDKs (Android/iOS). On Web it has no
  // implementation, so calling into it can crash at runtime (blank screen).
  if (_isMapboxSupportedPlatform) {
    try {
      MapboxOptions.setAccessToken(mapboxAccessToken);
    } catch (_) {
      // Best-effort: avoid crashing the whole app on unsupported platforms.
    }
  }

  runApp(const TripSyncApp());
}

bool get _isMapboxSupportedPlatform {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

class TripSyncApp extends StatefulWidget {
  const TripSyncApp({super.key});

  @override
  State<TripSyncApp> createState() => _TripSyncAppState();
}

class _TripSyncAppState extends State<TripSyncApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/app/start.jpg'), context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripSync',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.start,
      routes: AppRoutes.routes,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: false),
    );
  }
}
