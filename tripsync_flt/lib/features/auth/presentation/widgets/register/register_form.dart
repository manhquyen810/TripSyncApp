import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
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

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static const _labelStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    color: Color(0xFF6A7282),
    height: 1.43,
  );
  static const _hintStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    color: Color(0x800A0A0A),
  );
  static const _borderColor = Color(0xFFE5E7EB);
  static const _iconColor = Color(0xFF99A1AF);
  static const _borderRadius = BorderRadius.all(Radius.circular(16));
  static const _border = OutlineInputBorder(
    borderRadius: _borderRadius,
    borderSide: BorderSide(color: _borderColor),
  );
  static const _checkboxShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(4)),
  );

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text('Họ và tên', style: _labelStyle),
              ),
              TextFormField(
                controller: widget.fullNameController,
                enabled: !widget.isLoading,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                enableSuggestions: false,
                autocorrect: false,
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.isEmpty) return 'Vui lòng nhập họ và tên';
                  if (v.length < 2) return 'Họ và tên quá ngắn';
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Nhập họ và tên',
                  hintStyle: _hintStyle,
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: _iconColor,
                    size: 20,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  enabledBorder: _border,
                  focusedBorder: _border,
                  errorBorder: _border,
                  focusedErrorBorder: _border,
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text('Email', style: _labelStyle),
              ),
              TextFormField(
                controller: widget.emailController,
                enabled: !widget.isLoading,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                enableSuggestions: false,
                autocorrect: false,
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.isEmpty) return 'Vui lòng nhập email';
                  if (!_emailRegex.hasMatch(v)) return 'Email không hợp lệ';
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Nhập email',
                  hintStyle: _hintStyle,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: _iconColor,
                    size: 20,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  enabledBorder: _border,
                  focusedBorder: _border,
                  errorBorder: _border,
                  focusedErrorBorder: _border,
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text('Mật khẩu', style: _labelStyle),
              ),
              TextFormField(
                controller: widget.passwordController,
                enabled: !widget.isLoading,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                enableSuggestions: false,
                autocorrect: false,
                validator: (value) {
                  final v = (value ?? '');
                  if (v.isEmpty) return 'Vui lòng nhập mật khẩu';
                  if (v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Nhập mật khẩu',
                  hintStyle: _hintStyle,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: _iconColor,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _iconColor,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  enabledBorder: _border,
                  focusedBorder: _border,
                  errorBorder: _border,
                  focusedErrorBorder: _border,
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text('Xác nhận mật khẩu', style: _labelStyle),
              ),
              TextFormField(
                controller: widget.confirmPasswordController,
                enabled: !widget.isLoading,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                enableSuggestions: false,
                autocorrect: false,
                validator: (value) {
                  final v = (value ?? '');
                  if (v.isEmpty) return 'Vui lòng nhập lại mật khẩu';
                  if (v != widget.passwordController.text) {
                    return 'Mật khẩu không khớp';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Nhập lại mật khẩu',
                  hintStyle: _hintStyle,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: _iconColor,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _iconColor,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  enabledBorder: _border,
                  focusedBorder: _border,
                  errorBorder: _border,
                  focusedErrorBorder: _border,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: widget.agreeToTerms,
                  onChanged: widget.isLoading ? null : widget.onTermsChanged,
                  activeColor: const Color(0xFF72BF83),
                  shape: _checkboxShape,
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

          SizedBox(
            width: double.infinity,
            height: 51,
            child: ElevatedButton(
              onPressed: (!widget.agreeToTerms || widget.isLoading)
                  ? null
                  : () => widget.onRegister(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF72BF83),
                disabledBackgroundColor: const Color(0x8072BF83),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                widget.isLoading ? 'Đang đăng ký...' : 'Đăng ký',
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
