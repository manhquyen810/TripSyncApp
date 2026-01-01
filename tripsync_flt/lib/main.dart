import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const TripSyncApp());
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
    precacheImage(
      const AssetImage('assets/images/app/start.jpg'),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripSync',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.start,
      routes: AppRoutes.routes,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
    );
  }
}
