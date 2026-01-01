class Trip {
  final int? id;
  final String title;
  final String location;
  final String imageUrl;
  final int memberCount;
  final List<String> memberColors;
  final String startDate;
  final String endDate;
  final int daysCount;
  final int confirmedCount;
  final int proposedCount;

  const Trip({
    this.id,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.memberCount,
    required this.memberColors,
    required this.startDate,
    required this.endDate,
    required this.daysCount,
    required this.confirmedCount,
    required this.proposedCount,
  });
}
