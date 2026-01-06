import '../../domain/entities/trip_member.dart';

class TripMemberModel {
  final int id;
  final String name;
  final String email;

  TripMemberModel({required this.id, required this.name, required this.email});

  factory TripMemberModel.fromJson(Map<String, dynamic> json) {
    return TripMemberModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  TripMember toEntity() {
    return TripMember(id: id, name: name, email: email);
  }
}
