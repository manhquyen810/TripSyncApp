abstract interface class AuthRepository {
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  });

  /// Swagger defines this endpoint as `application/x-www-form-urlencoded`.
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  });

  /// Optional per OpenAPI security scheme tokenUrl.
  Future<Map<String, dynamic>> token({
    required String username,
    required String password,
  });

  Future<Map<String, dynamic>> me();
}
