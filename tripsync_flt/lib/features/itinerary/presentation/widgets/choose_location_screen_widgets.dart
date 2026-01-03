part of '../screens/choose_location_screen.dart';

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  static const Color _text = Color(0xFF111827);
  static const Color _border = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onBack,
                  child: const Icon(Icons.arrow_back, size: 24),
                ),
              ),
            ),
            const Spacer(),
            _FrostedPill(
              blur: 6,
              borderRadius: 16,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 21, vertical: 11),
                child: Text(
                  'Chọn địa điểm',
                  style: TextStyle(
                    fontSize: 16,
                    height: 24 / 16,
                    fontWeight: FontWeight.w700,
                    color: _text,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  static const Color _border = Color(0xFFE5E7EB);
  static const Color _mutedText = Color(0xFF6B7280);
  static const Color _green = Color(0xFF00D26A);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      left: 16,
      right: 16,
      top: topPadding + 72,
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: Row(
            children: [
              Icon(Icons.search, color: _green, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Tìm kiếm địa điểm...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _mutedText,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                height: 32,
                child: Material(
                  color: Colors.transparent,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([controller, focusNode]),
                    builder: (context, _) {
                      final hasText = controller.text.trim().isNotEmpty;
                      final showClear = focusNode.hasFocus && hasText;

                      return InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: showClear
                            ? () {
                                controller.clear();
                                onChanged('');
                                focusNode.requestFocus();
                              }
                            : () {},
                        child: Icon(
                          showClear ? Icons.close : Icons.tune,
                          size: 22,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultsOverlay extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<_PlaceResult> results;
  final ValueChanged<_PlaceResult> onSelect;

  const _SearchResultsOverlay({
    required this.loading,
    required this.error,
    required this.results,
    required this.onSelect,
  });

  static const Color _border = Color(0xFFE5E7EB);
  static const Color _mutedText = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      left: 16,
      right: 16,
      top: topPadding + 72 + 52 + 8,
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 320),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Builder(
              builder: (_) {
                if (loading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (error != null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final r = results[index];
                    return ListTile(
                      title: Text(
                        r.placeName?.isNotEmpty == true
                            ? r.placeName!
                            : r.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: (r.address?.isNotEmpty == true)
                          ? Text(
                              r.address!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: _mutedText),
                            )
                          : null,
                      onTap: () => onSelect(r),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceResult {
  final String label;
  final String? placeName;
  final String? address;
  final double lat;
  final double lng;
  final String? mapboxId;

  const _PlaceResult({
    required this.label,
    required this.lat,
    required this.lng,
    this.placeName,
    this.address,
    this.mapboxId,
  });
}

class _SelectedPinOverlay extends StatelessWidget {
  const _SelectedPinOverlay();

  static const Color _green = Color(0xFF00D26A);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.08),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FrostedPill(
            borderRadius: 8,
            blur: 2,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              child: Text(
                'Vị trí đã chọn',
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(width: 48, height: 58),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              Icon(Icons.place, size: 46, color: _green),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  final String title;
  final String address;
  final String? distanceText;
  final String? routeError;
  final bool routeLoading;
  final VoidCallback? onMyLocation;
  final VoidCallback? onRoute;
  final VoidCallback? onConfirm;

  const _BottomSheet({
    required this.title,
    required this.address,
    required this.distanceText,
    required this.routeError,
    required this.routeLoading,
    required this.onMyLocation,
    required this.onRoute,
    required this.onConfirm,
  });

  static const Color _text = Color(0xFF111827);
  static const Color _mutedText = Color(0xFF6B7280);
  static const Color _border = Color(0xFFF3F4F6);
  static const Color _outline = Color(0xFFD1D5DB);
  static const Color _green = Color(0xFF00D26A);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _border),
                      ),
                      child: const Icon(
                        Icons.store_mall_directory_outlined,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                height: 22.5 / 18,
                                fontWeight: FontWeight.w700,
                                color: _text,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              address,
                              style: TextStyle(
                                fontSize: 14,
                                height: 20 / 14,
                                fontWeight: FontWeight.w400,
                                color: _mutedText,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            if (distanceText != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                distanceText!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 18 / 13,
                                  fontWeight: FontWeight.w600,
                                  color: _text,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                            if (routeError != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                routeError!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 16 / 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.redAccent,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: _border),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _outline),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D000000),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: routeLoading ? null : onRoute,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (routeLoading)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: _green,
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.alt_route,
                                    size: 20,
                                    color: _green,
                                  ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Chọn đường đi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 20 / 14,
                                    fontWeight: FontWeight.w600,
                                    color: _text,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _outline),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: onMyLocation,
                          child: const Icon(Icons.my_location, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text(
                      'Xác nhận vị trí',
                      style: TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
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

class _FrostedPill extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;

  const _FrostedPill({
    required this.child,
    this.blur = 6,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: const Color(0xFFF3F4F6)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
