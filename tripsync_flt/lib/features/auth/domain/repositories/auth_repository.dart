abstract interface class AuthRepository {
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  });

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  });

  Future<Map<String, dynamic>> token({
    required String username,
    required String password,
  });

  Future<Map<String, dynamic>> me();

  Future<Map<String, dynamic>> forgotPassword({required String email});

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  });

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? avatarUrl,
  });

  /// Upload avatar image and return a public URL.
  ///
  /// - On mobile/desktop, pass [filePath].
  /// - On web, pass [bytes] and [filename] (FilePicker usually has no path).
  Future<String> uploadAvatar({
    String? filePath,
    List<int>? bytes,
    String? filename,
  });
}
