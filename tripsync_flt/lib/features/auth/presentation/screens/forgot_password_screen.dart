import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/exceptions.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../widgets/forgot_password/email_input_step.dart';
import '../widgets/forgot_password/otp_verification_step.dart';
import '../widgets/forgot_password/reset_password_step.dart';
import '../widgets/forgot_password/success_dialog.dart';
import '../../../../shared/widgets/top_toast.dart';

enum ForgotPasswordStep { emailInput, otpVerification, resetPassword }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  ForgotPasswordStep _currentStep = ForgotPasswordStep.emailInput;
  bool _isSubmitting = false;

  final TextEditingController emailController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _resetPasswordFormKey = GlobalKey<FormState>();

  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepositoryImpl(AuthRemoteDataSourceImpl(ApiClient()));
  }

  @override
  void dispose() {
    emailController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String get _otp => otpControllers.map((c) => c.text).join();

  Future<void> _handleSendOtp() async {
    if (_isSubmitting) return;
    final formState = _emailFormKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authRepository.forgotPassword(email: emailController.text.trim());

      if (mounted) {
        showTopToast(
          context,
          message: 'Mã xác minh đã được gửi đến email của bạn',
          type: TopToastType.success,
        );
        setState(() {
          _currentStep = ForgotPasswordStep.otpVerification;
        });
      }
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
          message: 'Gửi mã thất bại: $e',
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

  Future<void> _handleVerifyOtp() async {
    if (_isSubmitting) return;
    if (_otp.length < 5) {
      showTopToast(
        context,
        message: 'Vui lòng nhập đầy đủ mã xác minh',
        type: TopToastType.error,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authRepository.verifyOtp(
        email: emailController.text.trim(),
        otp: _otp,
      );

      if (mounted) {
        setState(() {
          _currentStep = ForgotPasswordStep.resetPassword;
        });
      }
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
          message: 'Xác minh thất bại: $e',
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

  Future<void> _handleResetPassword() async {
    if (_isSubmitting) return;
    final formState = _resetPasswordFormKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authRepository.resetPassword(
        email: emailController.text.trim(),
        otp: _otp,
        newPassword: newPasswordController.text,
      );

      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const SuccessDialog(
            title: 'Hoàn thành',
            message:
                'Mật khẩu của bạn đã được thay đổi.\nNhấn vào tiếp tục để đăng nhập.',
            buttonText: 'Tiếp tục',
          ),
        );

        if (!mounted) return;
        Navigator.of(context).pop();
      }
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
          message: 'Đặt lại mật khẩu thất bại: $e',
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

  Future<void> _handleResendOtp() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authRepository.forgotPassword(email: emailController.text.trim());

      if (mounted) {
        for (var controller in otpControllers) {
          controller.clear();
        }

        showTopToast(
          context,
          message: 'Mã xác minh đã được gửi lại',
          type: TopToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        showTopToast(
          context,
          message: 'Gửi lại mã thất bại',
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
    return Material(
      color: Colors.white,
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1D1D1D),
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      color: Color(0xFF1D1D1D),
                      size: 15,
                    ),
                    onPressed: () {
                      if (_currentStep == ForgotPasswordStep.emailInput) {
                        Navigator.pop(context);
                      } else {
                        setState(() {
                          if (_currentStep ==
                              ForgotPasswordStep.otpVerification) {
                            for (var controller in otpControllers) {
                              controller.clear();
                            }
                            _currentStep = ForgotPasswordStep.emailInput;
                          } else if (_currentStep ==
                              ForgotPasswordStep.resetPassword) {
                            _currentStep = ForgotPasswordStep.otpVerification;
                          }
                        });
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildCurrentStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case ForgotPasswordStep.emailInput:
        return EmailInputStep(
          formKey: _emailFormKey,
          emailController: emailController,
          onSubmit: _handleSendOtp,
          isLoading: _isSubmitting,
        );
      case ForgotPasswordStep.otpVerification:
        return OtpVerificationStep(
          email: emailController.text,
          otpControllers: otpControllers,
          onVerify: _handleVerifyOtp,
          onResendCode: _handleResendOtp,
          isLoading: _isSubmitting,
        );
      case ForgotPasswordStep.resetPassword:
        return ResetPasswordStep(
          formKey: _resetPasswordFormKey,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
          onSubmit: _handleResetPassword,
          isLoading: _isSubmitting,
        );
    }
  }
}
