import '../../domain/entities/settlement.dart';

class SettlementModel {
  final int? id;
  final int fromUserId;
  final int toUserId;
  final double amount;
  final String? createdAt;
  final FromUserModel? fromUser;
  final ToUserModel? toUser;

  SettlementModel({
    this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    this.createdAt,
    this.fromUser,
    this.toUser,
  });

  factory SettlementModel.fromJson(Map<String, dynamic> json) {
    return SettlementModel(
      id: json['id'],
      fromUserId: json['from_user_id'] ?? json['payer_id'],
      toUserId: json['to_user_id'] ?? json['receiver_id'],
      amount: (json['amount'] as num).toDouble(),
      createdAt: json['created_at'],
      fromUser: json['from_user'] != null || json['payer'] != null
          ? FromUserModel.fromJson(json['from_user'] ?? json['payer'])
          : null,
      toUser: json['to_user'] != null || json['receiver'] != null
          ? ToUserModel.fromJson(json['to_user'] ?? json['receiver'])
          : null,
    );
  }

  Settlement toEntity() {
    return Settlement(
      id: id,
      fromUserId: fromUserId,
      fromUserName: fromUser?.name ?? 'Unknown',
      toUserId: toUserId,
      toUserName: toUser?.name ?? 'Unknown',
      amount: amount,
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
    );
  }
}

class FromUserModel {
  final int id;
  final String name;

  FromUserModel({required this.id, required this.name});

  factory FromUserModel.fromJson(Map<String, dynamic> json) {
    return FromUserModel(id: json['id'], name: json['name']);
  }
}

class ToUserModel {
  final int id;
  final String name;

  ToUserModel({required this.id, required this.name});

  factory ToUserModel.fromJson(Map<String, dynamic> json) {
    return ToUserModel(id: json['id'], name: json['name']);
  }
}
