import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onForgotPassword;
  final Future<void> Function() onLogin;
  final bool isLoading;
  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onForgotPassword,
    required this.onLogin,
    this.isLoading = false,
    required this.rememberMe,
    required this.onRememberMeChanged,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
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
  static const _borderRadius = BorderRadius.all(Radius.circular(16));
  static const _border = OutlineInputBorder(
    borderRadius: _borderRadius,
    borderSide: BorderSide(color: Color(0xFFE5E7EB)),
  );

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
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
                    color: Color(0xFF99A1AF),
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
                    color: Color(0xFF99A1AF),
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF99A1AF),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: widget.rememberMe,
                      onChanged: widget.isLoading
                          ? null
                          : (v) => widget.onRememberMeChanged(v ?? false),
                      activeColor: const Color(0xFF72BF83),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Nhớ tài khoản',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF6A7282),
                      height: 1.43,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: widget.isLoading ? null : widget.onForgotPassword,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
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
            ],
          ),
          const SizedBox(height: 19),
          SizedBox(
            width: double.infinity,
            height: 51,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : () => widget.onLogin(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF72BF83),
                disabledBackgroundColor: const Color(0xFF72BF83),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                widget.isLoading ? 'Đang đăng nhập...' : 'Đăng nhập',
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
