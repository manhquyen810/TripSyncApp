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
}
