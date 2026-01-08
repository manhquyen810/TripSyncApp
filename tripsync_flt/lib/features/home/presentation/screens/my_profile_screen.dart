import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/auth_token_store.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../models/profile_data.dart';
import '../services/profile_store.dart';
import '../widgets/profile/profile_avatar.dart';
import '../widgets/profile/profile_stats_row.dart';
import '../widgets/profile/profile_top_bar.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  ProfileData _profile = ProfileData.demo;
  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepositoryImpl(
      AuthRemoteDataSourceImpl(
        ApiClient(authTokenProvider: AuthTokenStore.getAccessToken),
      ),
    );
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _loadLocalProfile();
    await _refreshFromApi();
  }

  Future<void> _loadLocalProfile() async {
    try {
      final loaded = await ProfileStore.load();
      if (!mounted) return;
      setState(() => _profile = loaded);
    } catch (_) {
      // If plugins aren't registered yet (hot reload after adding deps),
      // keep demo data and let user still update UI in-memory.
    }
  }

  Future<void> _refreshFromApi() async {
    try {
      final raw = await _authRepository.me();
      final merged = _mergeProfileFromMeResponse(_profile, raw);
      if (!mounted) return;

      if (merged != _profile) {
        setState(() => _profile = merged);
        try {
          await ProfileStore.save(merged);
        } catch (_) {
          // Ignore local save failure; UI is already updated.
        }
      }
    } on ApiException {
      // Ignore: user may not be logged in yet.
    } catch (_) {
      // Ignore: keep local profile.
    }
  }

  ProfileData _mergeProfileFromMeResponse(
    ProfileData current,
    Map<String, dynamic> raw,
  ) {
    final data = raw['data'];
    if (data is! Map<String, dynamic>) return current;

    final nextName = (data['name'] as String?)?.trim();
    final nextEmail = (data['email'] as String?)?.trim();
    final nextAvatarUrl = (data['avatar_url'] as String?)?.trim();

    final shouldUpdateName =
        nextName != null && nextName.isNotEmpty && nextName != current.name;
    final shouldUpdateEmail =
        nextEmail != null && nextEmail.isNotEmpty && nextEmail != current.email;

    final shouldUpdateAvatarUrl =
        nextAvatarUrl != null &&
        nextAvatarUrl.isNotEmpty &&
        nextAvatarUrl != current.avatarUrl;

    if (!shouldUpdateName && !shouldUpdateEmail && !shouldUpdateAvatarUrl) {
      return current;
    }

    return current.copyWith(
      name: shouldUpdateName ? nextName : null,
      email: shouldUpdateEmail ? nextEmail : null,
      avatarUrl: shouldUpdateAvatarUrl ? nextAvatarUrl : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              ProfileTopBar(
                title: 'Hồ sơ của tôi',
                onBack: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 32),
              _AvatarBlock(profile: _profile),
              const SizedBox(height: 18),
              const ProfileStatsRow(
                trips: '12',
                companions: '28',
                countries: '5',
              ),
              const SizedBox(height: 24),
              _InfoList(email: _profile.email),
              const Spacer(),
              SizedBox(
                width: 170,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.of(
                      context,
                    ).pushNamed('/edit-profile', arguments: _profile).then((
                      value,
                    ) async {
                      if (value is ProfileData) {
                        // Update UI immediately so avatar doesn't "disappear".
                        setState(() => _profile = value);
                        try {
                          final saved = await ProfileStore.save(value);
                          if (!mounted) return;
                          setState(() => _profile = saved);
                        } catch (_) {
                          if (!mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Không lưu được ảnh. Hãy Hot Restart app rồi thử lại.',
                              ),
                            ),
                          );
                        }
                      }
                    });
                  },
                  child: const Text(
                    'Chỉnh sửa hồ sơ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarBlock extends StatelessWidget {
  final ProfileData profile;

  const _AvatarBlock({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileAvatar(
          imageAsset: profile.avatarAsset,
          imageBytes: profile.avatarBytes,
          imageUrl: profile.avatarUrl,
        ),
        const SizedBox(height: 10),
        Text(
          profile.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _InfoList extends StatelessWidget {
  final String email;

  const _InfoList({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_InfoRow(icon: LucideIcons.mail, text: email)],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Poppins',
              color: Color(0xFF0A0A0A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
