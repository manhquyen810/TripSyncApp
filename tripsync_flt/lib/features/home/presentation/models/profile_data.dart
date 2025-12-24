import 'dart:typed_data';

class ProfileData {
  final String name;
  final String email;
  final String phone;
  final String address;
  final Uint8List? avatarBytes;
  final String? avatarPath;
  final String avatarAsset;

  const ProfileData({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.avatarBytes,
    this.avatarPath,
    this.avatarAsset = 'assets/images/trip/person.png',
  });

  ProfileData copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    Uint8List? avatarBytes,
    bool clearAvatarBytes = false,
    String? avatarPath,
    bool clearAvatarPath = false,
    String? avatarAsset,
  }) {
    return ProfileData(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarBytes: clearAvatarBytes ? null : (avatarBytes ?? this.avatarBytes),
      avatarPath: clearAvatarPath ? null : (avatarPath ?? this.avatarPath),
      avatarAsset: avatarAsset ?? this.avatarAsset,
    );
  }

  static const ProfileData demo = ProfileData(
    name: 'Nghiêm Quang Sáng',
    email: 'Nghiemquangsang312@gmail.com',
    phone: '09812340132123',
    address: 'Ứng Hòa, Hà Nội',
  );
}
