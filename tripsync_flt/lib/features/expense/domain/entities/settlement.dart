class Settlement {
  final int? id;
  final int fromUserId;
  final String fromUserName;
  final int toUserId;
  final String toUserName;
  final double amount;
  final DateTime? createdAt;

  const Settlement({
    this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.amount,
    this.createdAt,
  });
}
