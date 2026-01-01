import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/auth_token_store.dart';
import '../../../../core/network/exceptions.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../widgets/login/login_header.dart';
import '../widgets/login/login_tab_bar.dart';
import '../widgets/login/login_form.dart';
import '../widgets/login/login_card.dart';
import '../../../../shared/widgets/top_toast.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoginSelected = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepositoryImpl(AuthRemoteDataSourceImpl(ApiClient()));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isSubmitting) return;
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      Map<String, dynamic> raw = await _authRepository.login(
        username: email,
        password: password,
      );
      final data = raw['data'];
      final tokenFromLogin =
          (data is Map<String, dynamic> ? data['access_token'] : null) ??
          raw['access_token'];
      if (tokenFromLogin == null) {
        raw = await _authRepository.token(username: email, password: password);
      }

      final token = _extractAccessToken(raw);
      if (token != null) {
        await AuthTokenStore.saveAccessToken(token);
      }

      final message =
          (raw['message'] ?? raw['detail'] ?? 'Đăng nhập thành công')
              .toString();
      if (mounted) {
        showTopToast(context, message: message, type: TopToastType.success);
      }
      await Future<void>.delayed(const Duration(milliseconds: 650));

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (mounted) {
        final msg = switch (e) {
          TimeoutException() => 'Server đang khởi động, thử lại sau vài giây',
          UnauthorizedException() => 'Email hoặc mật khẩu không đúng',
          _ => e.message,
        };
        showTopToast(context, message: msg, type: TopToastType.error);
      }
    } catch (e) {
      if (mounted) {
        showTopToast(
          context,
          message: 'Đăng nhập thất bại: $e',
          type: TopToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String? _extractAccessToken(Map<String, dynamic> raw) {
    final data = raw['data'];
    final token =
        (data is Map<String, dynamic> ? data['access_token'] : null) ??
        raw['access_token'];
    if (token is String && token.trim().isNotEmpty) return token;
    return null;
  }

  void _handleForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 26.5, top: 45.5),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border(
                      top: BorderSide(color: Colors.white, width: 1.5),
                      left: BorderSide(color: Colors.white, width: 1.5),
                      right: BorderSide(color: Colors.white, width: 1.5),
                      bottom: BorderSide(color: Colors.white, width: 1.5),
                    ),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 15,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: LoginCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoginTabBar(
                      isLoginSelected: isLoginSelected,
                      onLoginTap: () {
                        setState(() {
                          isLoginSelected = true;
                        });
                      },
                      onSignupTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const RegisterScreen(),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: LoginForm(
                        formKey: _formKey,
                        emailController: emailController,
                        passwordController: passwordController,
                        onForgotPassword: _handleForgotPassword,
                        onLogin: _handleLogin,
                        isLoading: _isSubmitting,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
