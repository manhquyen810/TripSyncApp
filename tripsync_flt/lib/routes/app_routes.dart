import 'package:flutter/material.dart';
import '../features/start/screens/start_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/trip/presentation/screens/create_trip_screen.dart';
import '../features/itinerary/presentation/screens/itinerary_screen.dart';
import '../features/expense/presentation/screens/expense_screen.dart';
import '../features/expense/presentation/screens/add_expense_screen.dart';
import '../features/trip/domain/entities/trip.dart';

class AppRoutes {
  static const start = "/";
  static const login = "/login";
  static const trips = "/trips";
  static const register = "/register";
  static const home = "/home";
  static const createTrip = "/create-trip";
  static const itinerary = "/itinerary";
  static const expense = "/expense";
  static const addExpense = "/add-expense";

  static final routes = <String, WidgetBuilder>{
    start: (_) => const StartScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const HomeScreen(),
    createTrip: (_) => const CreateTripScreen(),
    itinerary: (context) {
      final trip = ModalRoute.of(context)!.settings.arguments as Trip;
      return TripItineraryScreen(trip: trip);
    },
    expense: (context) {
      final trip = ModalRoute.of(context)!.settings.arguments as Trip;
      return ExpenseScreen(trip: trip);
    },
    addExpense: (_) => const AddExpenseScreen(),
  };
}
