import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const TripSyncApp());
}

class TripSyncApp extends StatelessWidget {
  const TripSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripSync',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.start,
      routes: AppRoutes.routes,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
