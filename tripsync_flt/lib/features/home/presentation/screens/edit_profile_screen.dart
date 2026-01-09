import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/auth_token_store.dart';
import '../../../../core/network/exceptions.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../../shared/styles/app_colors.dart';
import '../models/profile_data.dart';
import '../widgets/profile/profile_avatar.dart';
import '../widgets/profile/profile_stats_row.dart';
import '../widgets/profile/profile_top_bar.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileData? initialData;

  const EditProfileScreen({super.key, this.initialData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final ProfileData _initialProfile;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  Uint8List? _avatarBytes;
  late final String _avatarAsset;
  String? _avatarPath;
  String? _avatarFileName;
  bool _avatarChanged = false;

  late final AuthRepository _authRepository;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepositoryImpl(
      AuthRemoteDataSourceImpl(
        ApiClient(authTokenProvider: AuthTokenStore.getAccessToken),
      ),
    );

    _initialProfile = widget.initialData ?? ProfileData.demo;
    _nameController = TextEditingController(text: _initialProfile.name);
    _emailController = TextEditingController(text: _initialProfile.email);
    _avatarBytes = _initialProfile.avatarBytes;
    _avatarPath = _initialProfile.avatarPath;
    _avatarAsset = _initialProfile.avatarAsset;
    _avatarFileName = null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
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
              const SizedBox(height: 28),
              _AvatarWithNameField(
                controller: _nameController,
                imageAsset: _avatarAsset,
                imageBytes: _avatarBytes,
                imageUrl: _initialProfile.avatarUrl,
                onPickAvatar: _pickAvatar,
              ),
              const SizedBox(height: 18),
              const ProfileStatsRow(
                trips: '12',
                companions: '28',
                countries: '5',
              ),
              const SizedBox(height: 20),
              _EditInfoList(emailController: _emailController),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                    label: 'Hủy',
                    isPrimary: false,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 28),
                  _ActionButton(
                    label: 'Lưu',
                    isPrimary: true,
                    onPressed: () async {
                      if (_isSaving) return;
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);
                      setState(() => _isSaving = true);

                      final name = _nameController.text.trim();
                      final email = _emailController.text.trim();

                      String? avatarUrl = _initialProfile.avatarUrl;
                      final shouldUploadAvatar = _avatarChanged;

                      if (shouldUploadAvatar) {
                        try {
                          avatarUrl = await _authRepository.uploadAvatar(
                            filePath: _avatarPath,
                            bytes: _avatarBytes,
                            filename: _avatarFileName,
                          );
                        } catch (e) {
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Không tải avatar lên server: $e'),
                            ),
                          );
                        }
                      }

                      final updated = ProfileData(
                        name: name,
                        email: email,
                        phone: _initialProfile.phone,
                        address: _initialProfile.address,
                        avatarUrl: avatarUrl,
                        avatarBytes: _avatarBytes,
                        avatarPath: _avatarPath,
                        avatarAsset: _avatarAsset,
                      );

                      try {
                        await _authRepository.updateProfile(
                          name: updated.name,
                          avatarUrl: updated.avatarUrl,
                        );
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Đã lưu hồ sơ lên server'),
                          ),
                        );
                      } on UnauthorizedException {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Vui lòng đăng nhập để lưu hồ sơ lên server',
                            ),
                          ),
                        );
                      } on ApiException catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Không lưu được lên server: ${e.message}',
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Không lưu được lên server: $e'),
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _isSaving = false);
                        }
                      }

                      if (!mounted) return;
                      navigator.pop(updated);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: false,
    );
    if (!mounted) return;

    final file = result?.files.single;
    final bytes = file?.bytes;
    if (bytes == null || bytes.isEmpty) {
      return;
    }

    setState(() {
      _avatarBytes = bytes;
      _avatarPath = file?.path;
      _avatarFileName = file?.name;
      _avatarChanged = true;
    });
  }
}

class _AvatarWithNameField extends StatelessWidget {
  final TextEditingController controller;
  final String imageAsset;
  final Uint8List? imageBytes;
  final String? imageUrl;
  final VoidCallback onPickAvatar;

  const _AvatarWithNameField({
    required this.controller,
    required this.imageAsset,
    required this.imageBytes,
    required this.imageUrl,
    required this.onPickAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileAvatar(
          imageAsset: imageAsset,
          imageBytes: imageBytes,
          imageUrl: imageUrl,
          onTap: onPickAvatar,
          showCameraBadge: true,
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 252),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF6A7282).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}

class _EditInfoList extends StatelessWidget {
  final TextEditingController emailController;

  const _EditInfoList({required this.emailController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EditInfoRow(
          icon: Icons.email_outlined,
          controller: emailController,
          width: 303,
        ),
      ],
    );
  }
}

class _EditInfoRow extends StatelessWidget {
  final IconData icon;
  final TextEditingController controller;
  final double width;

  const _EditInfoRow({
    required this.icon,
    required this.controller,
    required this.width,
  });

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
          child: Container(
            height: 40,
            constraints: BoxConstraints(maxWidth: width),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: TextField(
              controller: controller,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins',
                color: Color(0xFF0A0A0A),
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 135,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isPrimary ? AppColors.primary : Colors.white,
          foregroundColor: isPrimary ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: isPrimary ? null : const BorderSide(color: Colors.black),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
