class Env {
  const Env._();
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://tripsync-95ol.onrender.com',
  );

  static const String docsPath = '/docs';

  static Uri get docsUri => Uri.parse('$apiBaseUrl$docsPath');
}
