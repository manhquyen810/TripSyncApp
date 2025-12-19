class ApiEndpoints {
  const ApiEndpoints._();

  // ===== Auth =====
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';

  static const String authToken = '/auth/token';

  // ===== Users =====
  static const String usersMe = '/users/me';

  // ===== Trips =====
  static const String trips = '/trips';
  static String tripDetail(int tripId) => '/trips/$tripId';
  static const String tripsJoin = '/trips/join';

  // ===== Itinerary =====
  static const String itineraryCreateDay = '/itinerary/days';
  static const String itineraryActivities = '/itinerary/activities';
  static String itineraryVoteActivity(int activityId) =>
      '/itinerary/activities/$activityId/vote';
  static String itineraryActivitiesByDay({
    required int tripId,
    required int dayNumber,
  }) => '/itinerary/trips/$tripId/days/$dayNumber/activities';

  // ===== Expenses =====
  static const String expenses = '/expenses';
  static String expensesByTrip(int tripId) => '/expenses/trip/$tripId';
  static String expensesBalances(int tripId) =>
      '/expenses/trip/$tripId/balances';
  static const String expensesSettle = '/expenses/settle';
  static String expensesSettlements(int tripId) =>
      '/expenses/settle/trip/$tripId';

  // ===== Documents =====
  static const String documentsUpload = '/documents/upload';
  static String documentsByTrip(int tripId) => '/documents/trip/$tripId';

  // ===== Checklist =====
  static const String checklistAddItem = '/checklist/item';
  static String checklistToggleItem(int itemId) =>
      '/checklist/item/$itemId/toggle';
}
