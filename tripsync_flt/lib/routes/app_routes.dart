import 'package:flutter/material.dart';
import '../features/start/screens/start_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/home/presentation/screens/edit_profile_screen.dart';
import '../features/home/presentation/screens/my_profile_screen.dart';
import '../features/home/presentation/screens/settings_screen.dart';
import '../features/trip/presentation/screens/create_trip_screen.dart';
import '../features/home/presentation/models/profile_data.dart';
import '../features/itinerary/presentation/screens/itinerary_screen.dart';
import '../features/checklist/presentation/screens/checklist_screen.dart';
import '../features/expense/presentation/screens/expense_screen_dynamic.dart';
import '../features/documents/presentation/screens/document_management_screen.dart';
import '../features/trip/domain/entities/trip.dart';

class AppRoutes {
  static const start = "/";
  static const login = "/login";
  static const trips = "/trips";
  static const register = "/register";
  static const home = "/home";
  static const createTrip = "/create-trip";
  static const itinerary = "/itinerary";
  static const editProfile = "/edit-profile";
  static const myProfile = "/my-profile";
  static const settings = "/settings";
  static const checklist = "/checklist";
  static const expense = "/expense";
  static const documents = "/documents";

  static final routes = <String, WidgetBuilder>{
    start: (_) => const StartScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const HomeScreen(),
    createTrip: (_) => const CreateTripScreen(),
    documents: (context) {
      final trip = ModalRoute.of(context)!.settings.arguments as Trip;
      return DocumentManagementScreen(trip: trip);
    },
    editProfile: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      return EditProfileScreen(initialData: args is ProfileData ? args : null);
    },
    myProfile: (_) => const MyProfileScreen(),
    settings: (_) => const SettingsScreen(),
    itinerary: (context) {
      final trip = ModalRoute.of(context)!.settings.arguments as Trip;
      return TripItineraryScreen(trip: trip);
    },
    checklist: (context) {
      final trip = ModalRoute.of(context)!.settings.arguments as Trip;
      return ChecklistScreen(trip: trip);
    },
    expense: (context) {
      final trip = ModalRoute.of(context)!.settings.arguments as Trip?;
      if (trip == null) {
        return const Scaffold(
          body: Center(child: Text('Không tìm thấy chuyến đi')),
        );
      }
      return ExpenseScreen(trip: trip);
    },
  };
}
