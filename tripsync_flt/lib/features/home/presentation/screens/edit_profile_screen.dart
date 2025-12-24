import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
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
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  Uint8List? _avatarBytes;
  late final String _avatarAsset;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData ?? ProfileData.demo;
    _nameController = TextEditingController(text: initial.name);
    _emailController = TextEditingController(text: initial.email);
    _phoneController = TextEditingController(text: initial.phone);
    _addressController = TextEditingController(text: initial.address);
    _avatarBytes = initial.avatarBytes;
    _avatarPath = initial.avatarPath;
    _avatarAsset = initial.avatarAsset;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
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
                onPickAvatar: _pickAvatar,
              ),
              const SizedBox(height: 18),
              const ProfileStatsRow(
                trips: '12',
                companions: '28',
                countries: '5',
              ),
              const SizedBox(height: 20),
              _EditInfoList(
                emailController: _emailController,
                phoneController: _phoneController,
                addressController: _addressController,
              ),
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
                    onPressed: () {
                      final updated = ProfileData(
                        name: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        phone: _phoneController.text.trim(),
                        address: _addressController.text.trim(),
                        avatarBytes: _avatarBytes,
                        avatarPath: _avatarPath,
                        avatarAsset: _avatarAsset,
                      );
                      Navigator.of(context).pop(updated);
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
    });
  }
}

class _AvatarWithNameField extends StatelessWidget {
  final TextEditingController controller;
  final String imageAsset;
  final Uint8List? imageBytes;
  final VoidCallback onPickAvatar;

  const _AvatarWithNameField({
    required this.controller,
    required this.imageAsset,
    required this.imageBytes,
    required this.onPickAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileAvatar(
          imageAsset: imageAsset,
          imageBytes: imageBytes,
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
  final TextEditingController phoneController;
  final TextEditingController addressController;

  const _EditInfoList({
    required this.emailController,
    required this.phoneController,
    required this.addressController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EditInfoRow(
          icon: Icons.email_outlined,
          controller: emailController,
          width: 303,
        ),
        const SizedBox(height: 16),
        _EditInfoRow(
          icon: Icons.phone_outlined,
          controller: phoneController,
          width: 305,
        ),
        const SizedBox(height: 16),
        _EditInfoRow(
          icon: Icons.location_on_outlined,
          controller: addressController,
          width: 305,
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
