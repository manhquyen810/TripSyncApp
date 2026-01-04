class ApiEndpoints {
  const ApiEndpoints._();

  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';

  static const String authToken = '/auth/token';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String authResetPassword = '/auth/reset-password';

  static const String usersMe = '/users/me';
  static const String usersMeAvatarUpload = '/users/me/avatar';

  static const String trips = '/trips';
  static String tripDetail(int tripId) => '/trips/$tripId';
  static String tripMembers(int tripId) => '/trips/$tripId/members';
  static const String tripsJoin = '/trips/join';

  static const String itineraryCreateDay = '/itinerary/days';
  static String itineraryTrip(int tripId) => '/itinerary/trip/$tripId';
  static String itineraryDayActivities(int dayId) =>
      '/itinerary/days/$dayId/activities';

  static const String itineraryActivities = '/itinerary/activities';
  static String itineraryActivity(int activityId) =>
      '/itinerary/activities/$activityId';
  static String itineraryConfirmActivity(int activityId) =>
      '/itinerary/activities/$activityId/confirm';
  static String itineraryVoteActivity(int activityId) =>
      '/itinerary/activities/$activityId/vote';
  static String itineraryActivitiesByDay({
    required int tripId,
    required int dayNumber,
  }) => '/itinerary/trips/$tripId/days/$dayNumber/activities';

  static String itineraryTripLocations(int tripId) =>
      '/itinerary/trip/$tripId/locations';

  static const String expenses = '/expenses';
  static String expensesByTrip(int tripId) => '/expenses/trip/$tripId';
  static String expensesBalances(int tripId) =>
      '/expenses/trip/$tripId/balances';
  static const String expensesSettle = '/expenses/settle';
  static String expensesSettlements(int tripId) =>
      '/expenses/settle/trip/$tripId';

  static const String documentsUpload = '/documents/upload';
  static String documentsByTrip(int tripId) => '/documents/trip/$tripId';
    static String documentDetail(int documentId) => '/documents/$documentId';

  static const String checklistAddItem = '/checklist/item';
  static String checklistToggleItem(int itemId) =>
      '/checklist/item/$itemId/toggle';
    static String checklistTrip(int tripId) => '/checklist/trip/$tripId';
    static String checklistItemDetail(int itemId) => '/checklist/item/$itemId';
}
