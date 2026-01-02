import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    return _remote.register(email: email, password: password, name: name);
  }

  @override
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    return _remote.login(username: username, password: password);
  }

  @override
  Future<Map<String, dynamic>> token({
    required String username,
    required String password,
  }) async {
    return _remote.token(username: username, password: password);
  }

  @override
  Future<Map<String, dynamic>> me() async {
    return _remote.me();
  }

  @override
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    return _remote.forgotPassword(email: email);
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    return _remote.verifyOtp(email: email, otp: otp);
  }

  @override
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    return _remote.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? avatarUrl,
  }) async {
    return _remote.updateProfile(name: name, avatarUrl: avatarUrl);
  }

  @override
  Future<String> uploadAvatar({
    String? filePath,
    List<int>? bytes,
    String? filename,
  }) {
    return _remote.uploadAvatar(
      filePath: filePath,
      bytes: bytes,
      filename: filename,
    );
  }
}
