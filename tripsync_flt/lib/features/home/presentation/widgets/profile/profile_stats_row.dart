import 'package:flutter/material.dart';

class ProfileStatsRow extends StatelessWidget {
  final String trips;
  final String companions;
  final String countries;

  const ProfileStatsRow({
    super.key,
    required this.trips,
    required this.companions,
    required this.countries,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF99A1AF).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ProfileStatItem(value: trips, label: 'Chuyến đi'),
          _ProfileStatItem(value: companions, label: 'Bạn đồng hành'),
          _ProfileStatItem(value: countries, label: 'Quốc gia'),
        ],
      ),
    );
  }
}

class _ProfileStatItem extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Poppins',
              color: Colors.black,
              height: 20 / 12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Poppins',
              color: Colors.black,
              height: 20 / 12,
            ),
          ),
        ],
      ),
    );
  }
}
