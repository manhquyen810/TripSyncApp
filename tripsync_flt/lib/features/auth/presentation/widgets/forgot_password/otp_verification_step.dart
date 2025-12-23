import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'forgot_password_header.dart';

class OtpVerificationStep extends StatefulWidget {
  final String email;
  final List<TextEditingController> otpControllers;
  final Future<void> Function() onVerify;
  final Future<void> Function() onResendCode;
  final bool isLoading;

  const OtpVerificationStep({
    super.key,
    required this.email,
    required this.otpControllers,
    required this.onVerify,
    required this.onResendCode,
    this.isLoading = false,
  });

  @override
  State<OtpVerificationStep> createState() => _OtpVerificationStepState();
}

class _OtpVerificationStepState extends State<OtpVerificationStep> {
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 3) {
      return '${username[0]}***@$domain';
    }
    
    final visibleChars = username.substring(0, 3);
    return '$visibleChars***@$domain';
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 4) {
      _focusNodes[index + 1].requestFocus();
    }
    
    if (index == 4 && value.length == 1) {
      final allFilled = widget.otpControllers.every((c) => c.text.isNotEmpty);
      if (allFilled && !widget.isLoading) {
        widget.onVerify();
      }
    }
  }

  void _onOtpBackspace(int index) {
    if (index > 0 && widget.otpControllers[index].text.isEmpty) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ForgotPasswordHeader(
          title: 'Kiểm tra email',
          description: 'Đã gửi email với mã xác minh đến\n${_maskEmail(widget.email)}\nNhập mã dưới đây',
        ),
        
        const SizedBox(height: 48),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            return SizedBox(
              width: 56,
              height: 56,
              child: TextField(
                controller: widget.otpControllers[index],
                focusNode: _focusNodes[index],
                enabled: !widget.isLoading,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF3B30),
                  height: 1.33,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(
                      color: Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(
                      color: Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF3B30),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) => _onOtpChanged(value, index),
                onTap: () {
                  widget.otpControllers[index].clear();
                },
              ),
            );
          }),
        ),
        
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 51,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF72BF83),
              disabledBackgroundColor: const Color(0xFF72BF83),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              widget.isLoading ? 'Đang xử lý...' : 'Mã xác minh',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bạn vẫn chưa nhận được email? ',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF6A7282),
                height: 1.43,
              ),
            ),
            GestureDetector(
              onTap: widget.isLoading ? null : widget.onResendCode,
              child: Text(
                'Gửi lại email',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: widget.isLoading 
                      ? const Color(0xFF6A7282) 
                      : const Color(0xFF72BF83),
                  fontWeight: FontWeight.w600,
                  height: 1.43,
                  decoration: TextDecoration.underline,
                  decorationColor: widget.isLoading 
                      ? const Color(0xFF6A7282) 
                      : const Color(0xFF72BF83),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
