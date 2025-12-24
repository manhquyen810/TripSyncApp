import 'package:flutter/material.dart';
import '../../../../shared/widgets/trip_bottom_navigation.dart';
import '../../../../shared/widgets/trip_header.dart';
import '../../../../shared/widgets/add_floating_button.dart';
import '../../../trip/domain/entities/trip.dart';
import '../../../home/presentation/widgets/member_avatar.dart';

class TripItineraryScreen extends StatelessWidget {
  final Trip trip;

  const TripItineraryScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            TripHeader(
              title: trip.title,
              location: trip.location,
            ),

            // Trip Image and Info
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTripImageCard(),
                    const SizedBox(height: 4),
                    _buildMemberInfo(),
                    const SizedBox(height: 16),
                    _buildDateSection(),
                    const SizedBox(height: 16),
                    _buildStatsSection(),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                    const SizedBox(height: 16),
                    _buildItineraryList(),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            TripBottomNavigation(
              currentIndex: 0,
              onTap: (index) {
                if (index == 0) return; // Already on itinerary screen
                
                switch (index) {
                  case 0:
                    // Itinerary screen (current)
                    break;
                  case 1:
                    // TODO: Navigate to Upload/Document screen
                    break;
                  case 2:
                    // TODO: Navigate to Expense screen
                    break;
                  case 3:
                    // TODO: Navigate to Checklist screen
                    break;
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: const AddFloatingButton(),
    );
  }

  Widget _buildTripImageCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 235,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(trip.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 11,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/location.png',
                          width: 20,
                          height: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trip.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Image.asset('assets/icons/group.png', width: 24, height: 24),
            const SizedBox(width: 6),
            Text(
              '${trip.memberCount} thành viên',
              style: const TextStyle(fontSize: 14),
            ),
            const Spacer(),
            ...trip.memberColors
                .map(
                  (color) => MemberAvatar(
                    color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                    size: 25,
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 27),
      child: Row(
        children: [
          const Text(
            'Thời gian',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 12),
          _buildDateChip(trip.startDate),
          Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          _buildDateChip(trip.endDate),
        ],
      ),
    );
  }

  Widget _buildDateChip(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Image.asset('assets/icons/celendar.png', width: 20, height: 20),
          const SizedBox(width: 8),
          Text(date, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Ngày', '${trip.daysCount}', Colors.black),
          _buildStatItem(
            'Chốt',
            '${trip.confirmedCount}',
            const Color(0xFF00C950),
          ),
          _buildStatItem(
            'Đề xuất',
            '${trip.proposedCount}',
            const Color(0xFFFF6B6B),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C950),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '+ Thêm đề xuất hoạt động',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFC8C8C8).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: const Row(
              children: [
                Icon(Icons.map_outlined, size: 20),
                SizedBox(width: 4),
                Text('Bản đồ', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryList() {
    // Mock data structure - in real app, this would come from the Trip model
    final Map<int, List<Map<String, dynamic>>> dayActivities = {
      1: [
        {
          'title': 'Check-in Khách sạn Dalat Wonder Resort',
          'subtitle': 'Nhận phòng và nghỉ ngơi',
          'time': '14:00',
          'location': 'Đà Lạt Wonder Resort',
          'likes': '3 người thích',
          'isConfirmed': true,
          'proposedBy': 'Sáng',
        },
        {
          'title': 'Ăn tối tại Quán Gió Đà Lạt',
          'subtitle': 'Thưởng thức các món nướng đặc sản',
          'time': '19:00',
          'location': 'Quán Gió Đà Lạt, Đường 3 Tháng 2',
          'likes': '2 người thích',
          'isConfirmed': true,
          'proposedBy': 'Sáng',
        },
      ],
      2: [
        {
          'title': 'Check-in Khách sạn Dalat Wonder Resort',
          'subtitle': 'Nhận phòng và nghỉ ngơi',
          'time': '14:00',
          'location': 'Đà Lạt Wonder Resort',
          'isConfirmed': false,
          'proposedBy': 'Sáng',
          'likesCount': 2,
          'dislikes': 2,
        },
        {
          'title': 'Ăn tối tại Quán Gió Đà Lạt',
          'subtitle': 'Thưởng thức các món nướng đặc sản',
          'time': '19:00',
          'location': 'Quán Gió Đà Lạt, Đường 3 Tháng 2',
          'isConfirmed': false,
          'proposedBy': 'Sáng',
          'likesCount': 2,
          'dislikes': 2,
        },
      ],
      3: [], // Empty day to demonstrate "no activities" message
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 27),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...dayActivities.entries.map((entry) {
            final dayNumber = entry.key;
            final activities = entry.value;
            final confirmedCount = activities
                .where((a) => a['isConfirmed'] == true)
                .length;
            final proposedCount = activities
                .where((a) => a['isConfirmed'] == false)
                .length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dayNumber > 1) const SizedBox(height: 38),
                _buildDayHeader(
                  dayNumber,
                  '$confirmedCount đã chốt • $proposedCount đề xuất',
                ),
                const SizedBox(height: 17),
                if (activities.isEmpty)
                  Center(
                    child: Column(
                      children: const [
                        Text(
                          'Chưa có hoạt động',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF4A5565),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Thêm hoạt động đầu tiên',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFE7000B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...activities.asMap().entries.map((activityEntry) {
                    final index = activityEntry.key;
                    final activity = activityEntry.value;

                    return Column(
                      children: [
                        if (index > 0) const SizedBox(height: 11),
                        _buildActivityCard(
                          activity['title'],
                          activity['subtitle'],
                          activity['time'],
                          activity['location'],
                          activity['likes'],
                          isConfirmed: activity['isConfirmed'] ?? false,
                          proposedBy: activity['proposedBy'],
                          likesCount: activity['likesCount'],
                          dislikes: activity['dislikes'],
                        ),
                      ],
                    );
                  }).toList(),
              ],
            );
          }).toList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildDayHeader(int day, String subtitle) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFDC700), Color(0xFFFF8904)],
                  ),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ngày $day',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF101828),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 15, color: Color(0xFF6A7282)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityCard(
    String title,
    String subtitle,
    String time,
    String location,
    String? likes, {
    bool isConfirmed = false,
    String? proposedBy,
    int? likesCount,
    int? dislikes,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isConfirmed
            ? const Color(0xFFF3F4F6)
            : const Color(0xFFF3F4F6).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 7),
              Text(subtitle, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 7),
              Row(
                children: [
                  Image.asset('assets/icons/clock.png', width: 20, height: 20),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Image.asset(
                    'assets/icons/location.png',
                    width: 20,
                    height: 20,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              if (proposedBy != null) ...[
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 24,
                      child: Center(
                        child: OverflowBox(
                          maxWidth: 24,
                          maxHeight: 24,
                          child: Image.asset(
                            'assets/icons/person.png',
                            width: 24,
                            height: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isConfirmed ? proposedBy! : 'Đề xuất bởi $proposedBy',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
              ],
              if (likes != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C950).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.thumb_up,
                        size: 18,
                        color: Color(0xFF00C950),
                      ),
                      const SizedBox(width: 4),
                      Text(likes, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              if (!isConfirmed && proposedBy != null) ...[
                Row(
                  children: [
                    Container(
                      width: 135,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C950),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.thumb_up,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$likesCount',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 23),
                    Container(
                      width: 135,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.thumb_down, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '$dislikes',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          if (isConfirmed)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.only(top: 8, right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C950),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check, color: Colors.white, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Chốt',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!isConfirmed)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.only(top: 8, right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDC700),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Colors.black,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Đề xuất',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
