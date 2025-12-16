import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/favorite_features_section.dart';
import '../widgets/trip_list_header.dart';
import '../widgets/trip_card.dart';
import '../../../trip/presentation/screens/join_trip_screen.dart';

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
                          onProfileTap: () {},
                        ),

                        SizedBox(height: topSpacing),

                        FavoriteFeaturesSection(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          onJoinTripTap: () {
                            showJoinTripDialog(context);
                          },
                          onCreateTripTap: () {
                            Navigator.pushNamed(context, '/create-trip');
                          },
                          onProfileTap: () {},
                          onSettingsTap: () {},
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

    final trips = <_TripCardData>[
      _TripCardData(
        title: 'Đà Lạt-Thành Phố Mộng Mơ',
        location: 'Đà Lạt, Lâm Đồng',
        imageUrl: 'assets/images/app/trip_1.jpg',
        memberCount: 3,
        memberColors: const [
          Color(0xFFFF6B6B),
          Color(0xFFE59600),
          Color(0xFFA8E6CF),
        ],
      ),
      _TripCardData(
        title: 'Sapa- Xứ sở sương mù',
        location: 'Lào Cai',
        imageUrl: 'assets/images/app/trip_1.jpg',
        memberCount: 3,
        memberColors: const [
          Color(0xFFFF6B6B),
          Color(0xFFE59600),
          Color(0xFFA8E6CF),
        ],
      ),
      _TripCardData(
        title: 'Sapa- Xứ sở sương mù',
        location: 'Lào Cai',
        imageUrl: 'assets/images/app/trip_1.jpg',
        memberCount: 3,
        memberColors: const [
          Color(0xFFFF6B6B),
          Color(0xFFE59600),
          Color(0xFFA8E6CF),
        ],
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
                memberColors: trip.memberColors,
                cardWidth: cardWidth,
                imageHeight: imageHeight,
                onTap: () {},
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TripCardData {
  final String title;
  final String location;
  final String imageUrl;
  final int memberCount;
  final List<Color> memberColors;

  const _TripCardData({
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.memberCount,
    required this.memberColors,
  });
}
