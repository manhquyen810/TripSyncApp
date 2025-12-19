import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onForgotPassword;
  final Future<void> Function() onLogin;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onForgotPassword,
    required this.onLogin,
    this.isLoading = false,
  });

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      // Validate per-field as the user interacts, not the whole form.
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Email field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text(
                  'Email',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF6A7282),
                    height: 1.43,
                  ),
                ),
              ),
              TextFormField(
                controller: emailController,
                enabled: !isLoading,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.isEmpty) return 'Vui lòng nhập email';
                  if (!_emailRegex.hasMatch(v)) return 'Email không hợp lệ';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Nhập email',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: const Color(0xFF0A0A0A).withOpacity(0.5),
                  ),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF99A1AF),
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          // Password field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text(
                  'Mật khẩu',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF6A7282),
                    height: 1.43,
                  ),
                ),
              ),
              TextFormField(
                controller: passwordController,
                enabled: !isLoading,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                obscureText: true,
                validator: (value) {
                  final v = (value ?? '');
                  if (v.isEmpty) return 'Vui lòng nhập mật khẩu';
                  if (v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Nhập mật khẩu',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: const Color(0xFF0A0A0A).withOpacity(0.5),
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF99A1AF),
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          // Forgot password button
          TextButton(
            onPressed: isLoading ? null : onForgotPassword,
            child: const Text(
              'Quên mật khẩu?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF6A7282),
                height: 1.43,
              ),
            ),
          ),
          // Login button
          SizedBox(
            width: double.infinity,
            height: 51,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => onLogin(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF72BF83),
                disabledBackgroundColor: const Color(0xFF72BF83),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isLoading ? 'Đang đăng nhập...' : 'Đăng nhập',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
