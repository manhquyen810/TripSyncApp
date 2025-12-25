import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/favorite_features_section.dart';
import '../widgets/trip_list_header.dart';
import '../widgets/trip_card.dart';
import '../../../trip/presentation/screens/join_trip_screen.dart';
import '../../../trip/domain/entities/trip.dart';
import '../../../../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/app/home_trip.jpg'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double bottomPadding = 30;
              final double usableHeight =
                  (constraints.maxHeight - bottomPadding).clamp(
                    0.0,
                    double.infinity,
                  );

              const minSpacing = 16.0;
              const maxSpacing = 56.0;
              final topSpacing = (usableHeight * 0.18).clamp(
                minSpacing,
                maxSpacing,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: bottomPadding),
                child: SizedBox(
                  height: usableHeight,
                  child: ClipRect(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HomeHeader(
                          userName: 'nghiemqsang02',
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                          onProfileTap: () {
                            Navigator.of(context).pushNamed('/my-profile');
                          },
                        ),

                        SizedBox(height: topSpacing),

                        FavoriteFeaturesSection(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          onJoinTripTap: () {
                            showJoinTripDialog(context);
                          },
                          onCreateTripTap: () {
                            Navigator.of(context).pushNamed('/create-trip');
                          },
                          onProfileTap: () {
                            Navigator.of(context).pushNamed('/my-profile');
                          },
                          onSettingsTap: () {
                            Navigator.of(context).pushNamed('/settings');
                          },
                        ),

                        const SizedBox(height: 24),

                        TripListHeader(
                          activeTripCount: 2,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          onViewAllTap: () {},
                        ),

                        const SizedBox(height: 12),

                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, tripConstraints) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: _buildTripCards(
                                  context,
                                  maxHeight: tripConstraints.maxHeight,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTripCards(BuildContext context, {required double maxHeight}) {
    const horizontalPadding = 14.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - (horizontalPadding * 2);

    final cardWidth = availableWidth;

    const double cardAspectRatio = 16 / 9;

    const double bottomContentHeight = 50.0;
    const double minUsableImageHeight = 90.0;

    final preferredImageHeight = cardWidth / cardAspectRatio;
    final maxImageHeight = (maxHeight - bottomContentHeight).clamp(
      0.0,
      double.infinity,
    );

    if (maxImageHeight < minUsableImageHeight) {
      return const SizedBox.shrink();
    }

    final imageHeight = preferredImageHeight.clamp(0.0, maxImageHeight);

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
        title: 'Sapa- Xứ sở sương mù',
        location: 'Lào Cai',
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
        title: 'Hà Nội - Thủ đô ngàn năm',
        location: 'Hà Nội',
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

    return SizedBox(
      height: maxHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: PageView.builder(
          physics: const PageScrollPhysics(),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index];
            const cardGap = 12.0;
            final isFirst = index == 0;
            final isLast = index == trips.length - 1;

            return Padding(
              padding: EdgeInsets.only(
                left: isFirst ? 0 : cardGap / 2,
                right: isLast ? 0 : cardGap / 2,
              ),
              child: TripCard(
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
                cardWidth: cardWidth,
                imageHeight: imageHeight,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.itinerary,
                    arguments: trip,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
