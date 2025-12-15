import 'package:flutter/material.dart';
import '../features/start/screens/start_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';

class AppRoutes {
  static const start = "/";
  static const login = "/login";
  static const trips = "/trips";
  static const register = "/register";
  static const home = "/home";

  static final routes = <String, WidgetBuilder>{
    start: (_) => const StartScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const HomeScreen(),
  };
}
