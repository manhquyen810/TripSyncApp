import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../core/network/auth_token_store.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../routes/app_routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final dividerColor = AppColors.divider.withValues(alpha: 0.4);
    final errorColor = Theme.of(context).colorScheme.error;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      tooltip: 'Quay lại',
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Cài đặt',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.black,
                        height: 20 / 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  children: [
                    _SettingsToggleRow(
                      icon: Icons.phone_android,
                      label: 'Thông báo đẩy',
                      value: _pushNotificationsEnabled,
                      onChanged: (v) =>
                          setState(() => _pushNotificationsEnabled = v),
                    ),
                    const SizedBox(height: 10),
                    _SettingsToggleRow(
                      icon: Icons.email_outlined,
                      label: 'Thông báo email',
                      value: _emailNotificationsEnabled,
                      onChanged: (v) =>
                          setState(() => _emailNotificationsEnabled = v),
                    ),
                    const SizedBox(height: 10),
                    const _SettingsNavRow(
                      icon: Icons.volume_up_outlined,
                      label: 'Âm thanh',
                    ),
                    const SizedBox(height: 18),
                    Container(height: 2, color: dividerColor),
                    const SizedBox(height: 18),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text(
                          'Giao diện',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            color: Colors.black,
                            height: 20 / 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SettingsToggleRow(
                      icon: Icons.dark_mode_outlined,
                      label: 'Chế độ tối',
                      value: _darkModeEnabled,
                      onChanged: (v) => setState(() => _darkModeEnabled = v),
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(height: 18),
                    Container(height: 2, color: dividerColor),
                    const SizedBox(height: 10),
                    const _SettingsNavRow(
                      icon: Icons.language,
                      label: 'Ngôn ngữ',
                    ),
                    const SizedBox(height: 2),
                    const _SettingsNavRow(
                      icon: Icons.shield_outlined,
                      label: 'Bảo mật & Quyền riêng tư',
                    ),
                    const SizedBox(height: 2),
                    const _SettingsNavRow(
                      icon: Icons.headset_mic_outlined,
                      label: 'Trợ giúp & Hỗ trợ',
                    ),
                    const SizedBox(height: 18),
                    Container(height: 2, color: dividerColor),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
                child: Column(
                  children: [
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await AuthTokenStore.clear();
                          if (!kIsWeb) {
                            await SecureStorageService.deleteToken();
                          }
                          if (!context.mounted) return;
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.start,
                            (route) => false,
                            arguments: const <String, dynamic>{
                              'openLogin': true,
                            },
                          );
                        },
                        icon: Icon(Icons.logout, color: errorColor, size: 20),
                        label: Text(
                          'Đăng xuất',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            color: errorColor,
                            height: 20 / 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: errorColor, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: errorColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'TripSync phiên bản 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                        color: Colors.black,
                        height: 20 / 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  const _SettingsToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? AppColors.primary;
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.black),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
              color: Colors.black,
              height: 20 / 14,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: active,
          activeTrackColor: active.withValues(alpha: 0.35),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}

class _SettingsNavRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SettingsNavRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                color: Colors.black,
                height: 20 / 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
