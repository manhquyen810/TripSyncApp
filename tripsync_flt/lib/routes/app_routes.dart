import 'package:flutter/material.dart';
import '../features/start/screens/start_screen.dart';

class AppRoutes {
  static const start = "/";
  static const login = "/login";
  static const trips = "/trips";

  static final routes = <String, WidgetBuilder>{
    start: (_) => const StartScreen(),
  };
}
