import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum TopToastType { success, error }

void showTopToast(
  BuildContext context, {
  required String message,
  TopToastType type = TopToastType.success,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => _TopToastEntry(
      message: message,
      type: type,
      duration: duration,
      onDismissed: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );

  overlay.insert(entry);
}

class _TopToastEntry extends StatefulWidget {
  const _TopToastEntry({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final TopToastType type;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_TopToastEntry> createState() => _TopToastEntryState();
}

class _TopToastEntryState extends State<_TopToastEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 180),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _timer?.cancel();
    _controller.reverse().whenComplete(() {
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = widget.type == TopToastType.success;

    const successBg = Color(0xFF72BF83);
    const errorBg = Color(0xFFFF6B6B);

    final backgroundColor = isSuccess ? successBg : errorBg;
    final icon = isSuccess ? LucideIcons.check : LucideIcons.x;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Material(
                  elevation: 6,
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: _dismiss,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            alignment: Alignment.center,
                            child: Icon(icon, size: 18, color: backgroundColor),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              widget.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
