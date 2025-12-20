import 'package:flutter/material.dart';

class MemberInviteField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onAddPressed;

  const MemberInviteField({
    super.key,
    required this.controller,
    required this.onAddPressed,
  });

  @override
  State<MemberInviteField> createState() => _MemberInviteFieldState();
}

class _MemberInviteFieldState extends State<MemberInviteField> {
  bool isAddButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mời thành viên *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Focus(
                child: Builder(
                  builder: (context) {
                    final hasFocus = Focus.of(context).hasFocus;
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: hasFocus
                              ? const Color(0xFF00C950)
                              : Colors.black,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: widget.controller,
                        maxLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'Email thành viên',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFA8B1BE),
                            fontFamily: 'Poppins',
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 19),
            GestureDetector(
              onTapDown: (_) {
                setState(() {
                  isAddButtonPressed = true;
                });
              },
              onTapUp: (_) {
                setState(() {
                  isAddButtonPressed = false;
                });
                widget.onAddPressed();
              },
              onTapCancel: () {
                setState(() {
                  isAddButtonPressed = false;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isAddButtonPressed
                        ? const Color(0xFF00C950)
                        : Colors.black,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
