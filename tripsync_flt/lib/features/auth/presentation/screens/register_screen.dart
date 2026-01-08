import 'package:flutter/material.dart' hide TabBarView;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tripsync_flt/features/auth/presentation/screens/login_screen.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/exceptions.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../widgets/login/login_tab_bar.dart';
import '../widgets/login/login_card.dart';
import '../widgets/register/register_form.dart';
import '../../../../shared/widgets/top_toast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool agreeToTerms = false;

  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepositoryImpl(AuthRemoteDataSourceImpl(ApiClient()));
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_isSubmitting) return;
    if (!agreeToTerms) {
      showTopToast(
        context,
        message: 'Vui lòng đồng ý điều khoản',
        type: TopToastType.error,
      );
      return;
    }

    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final raw = await _authRepository.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        name: fullNameController.text.trim(),
      );

      final message = (raw['message'] ?? raw['detail'] ?? 'Đăng ký thành công')
          .toString();
      if (mounted) {
        showTopToast(context, message: message, type: TopToastType.success);
      }

      await Future<void>.delayed(const Duration(milliseconds: 650));

      if (!mounted) return;
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) {
        final msg = e is TimeoutException
            ? 'Server đang khởi động, thử lại sau vài giây'
            : e.message;
        showTopToast(context, message: msg, type: TopToastType.error);
      }
    } catch (e) {
      if (mounted) {
        showTopToast(
          context,
          message: 'Đăng ký thất bại: $e',
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

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
          ),
        ),
        child: SafeArea(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: bottomInset),
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
                          LucideIcons.arrowLeft,
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
                      children: [
                        LoginTabBar(
                          isLoginSelected: false,
                          onLoginTap: () {
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const LoginScreen(),
                            );
                          },
                          onSignupTap: () {},
                        ),

                        const SizedBox(height: 24),

                        Expanded(
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: RegisterForm(
                              formKey: _formKey,
                              fullNameController: fullNameController,
                              emailController: emailController,
                              passwordController: passwordController,
                              confirmPasswordController:
                                  confirmPasswordController,
                              agreeToTerms: agreeToTerms,
                              onTermsChanged: (value) {
                                setState(() {
                                  agreeToTerms = value ?? false;
                                });
                              },
                              onRegister: _handleRegister,
                              isLoading: _isSubmitting,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
