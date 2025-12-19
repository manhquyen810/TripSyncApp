import 'package:flutter/material.dart';

class RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool agreeToTerms;
  final ValueChanged<bool?> onTermsChanged;
  final Future<void> Function() onRegister;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.agreeToTerms,
    required this.onTermsChanged,
    required this.onRegister,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text(
                  'Họ và tên',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF6A7282),
                    height: 1.43,
                  ),
                ),
              ),
              TextFormField(
                controller: fullNameController,
                enabled: !isLoading,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.isEmpty) return 'Vui lòng nhập họ và tên';
                  if (v.length < 2) return 'Họ và tên quá ngắn';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Nhập họ và tên',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: const Color(0xFF0A0A0A).withOpacity(0.5),
                  ),
                  prefixIcon: const Icon(
                    Icons.person_outline,
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
                textInputAction: TextInputAction.next,
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
                textInputAction: TextInputAction.next,
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

          // Confirm Password field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text(
                  'Xác nhận mật khẩu',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF6A7282),
                    height: 1.43,
                  ),
                ),
              ),
              TextFormField(
                controller: confirmPasswordController,
                enabled: !isLoading,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  final v = (value ?? '');
                  if (v.isEmpty) return 'Vui lòng nhập lại mật khẩu';
                  if (v != passwordController.text) {
                    return 'Mật khẩu không khớp';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Nhập lại mật khẩu',
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
          const SizedBox(height: 16),

          // Terms checkbox
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: agreeToTerms,
                  onChanged: isLoading ? null : onTermsChanged,
                  activeColor: const Color(0xFF72BF83),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tôi đồng ý với Điều khoản sử dụng và Chính sách bảo mật',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF6A7282),
                    height: 1.43,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Register button
          SizedBox(
            width: double.infinity,
            height: 51,
            child: ElevatedButton(
              onPressed: (!agreeToTerms || isLoading)
                  ? null
                  : () => onRegister(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF72BF83),
                disabledBackgroundColor: const Color(
                  0xFF72BF83,
                ).withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isLoading ? 'Đang đăng ký...' : 'Đăng ký',
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
