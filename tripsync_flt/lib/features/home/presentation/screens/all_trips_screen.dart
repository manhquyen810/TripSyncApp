import 'package:flutter/material.dart';
import '../widgets/all_trips_header.dart';
import '../widgets/all_trips_search_bar.dart';
import '../widgets/trip_card.dart';
import '../../../trip/domain/entities/trip.dart';
import '../../../itinerary/presentation/screens/itinerary_screen.dart';

class AllTripsScreen extends StatelessWidget {
  const AllTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trips = <Trip>[
      const Trip(
        title: 'Đà Lạt-Thành Phố Mộng Mơ',
        location: 'Đà Lạt, Lâm Đồng',
        imageUrl: 'assets/images/app/trip_1.jpg',
        memberCount: 3,
        memberColors: ['#A8E6CF', '#E59600', '#FF6B6B'],
        startDate: '12/12/2025',
        endDate: '15/12/2025',
        daysCount: 3,
        confirmedCount: 2,
        proposedCount: 0,
      ),
      const Trip(
        title: 'Đà Lạt-Thành Phố Mộng Mơ',
        location: 'Đà Lạt, Lâm Đồng',
        imageUrl: 'assets/images/app/trip_1.jpg',
        memberCount: 3,
        memberColors: ['#A8E6CF', '#E59600', '#FF6B6B'],
        startDate: '20/12/2025',
        endDate: '23/12/2025',
        daysCount: 4,
        confirmedCount: 3,
        proposedCount: 1,
      ),
      const Trip(
        title: 'Đà Lạt-Thành Phố Mộng Mơ',
        location: 'Đà Lạt, Lâm Đồng',
        imageUrl: 'assets/images/app/trip_1.jpg',
        memberCount: 3,
        memberColors: ['#A8E6CF', '#E59600', '#FF6B6B'],
        startDate: '01/01/2026',
        endDate: '05/01/2026',
        daysCount: 5,
        confirmedCount: 4,
        proposedCount: 2,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),

            // Header Section
            AllTripsHeader(
              onCreateTripTap: () {
                Navigator.pushNamed(context, '/create-trip');
              },
            ),

            const SizedBox(height: 12),

            // Search Bar
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: AllTripsSearchBar(),
            ),

            const SizedBox(height: 16),

            // Trip List
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: trips.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                  final trip = trips[index];
                  return TripCard(
                    title: trip.title,
                    location: trip.location,
                    imageUrl: trip.imageUrl,
                    memberCount: trip.memberCount,
                    memberColors: trip.memberColors
                        .map(
                          (color) =>
                              Color(int.parse(color.replaceFirst('#', '0xFF'))),
                        )
                        .toList(),
                    cardWidth: double.infinity,
                    imageHeight: 235,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TripItineraryScreen(trip: trip),
                        ),
                      );
                    },
                  );
                },
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
