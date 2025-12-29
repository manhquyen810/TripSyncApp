import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/auth_token_store.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../shared/widgets/top_toast.dart';
import '../../../trip/data/datasources/trip_remote_data_source.dart';
import '../../../trip/data/repositories/trip_repository_impl.dart';
import '../../../trip/domain/repositories/trip_repository.dart';
import '../../../trip/presentation/services/trip_list_loader.dart';
import '../widgets/home_header.dart';
import '../widgets/favorite_features_section.dart';
import '../widgets/trip_list_header.dart';
import '../widgets/trip_card.dart';
import '../../../trip/presentation/screens/join_trip_screen.dart';
import '../../../trip/domain/entities/trip.dart';
import '../../../itinerary/presentation/screens/itinerary_screen.dart';
import 'all_trips_screen.dart';
import '../../../../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TripRepository _tripRepository;
  late Future<List<Trip>> _tripsFuture;

  bool _hasShownLoadError = false;

  @override
  void initState() {
    super.initState();
    _tripRepository = TripRepositoryImpl(
      TripRemoteDataSourceImpl(
        ApiClient(authTokenProvider: AuthTokenStore.getAccessToken),
      ),
    );
    _tripsFuture = _loadTrips();
  }

  void _refreshTrips() {
    setState(() {
      _hasShownLoadError = false;
      _tripsFuture = _loadTrips();
    });
  }

  Future<List<Trip>> _loadTrips() async {
    return TripListLoader.loadTrips(_tripRepository);
  }

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

              return FutureBuilder<List<Trip>>(
                future: _tripsFuture,
                builder: (context, snapshot) {
                  final trips = snapshot.data ?? const <Trip>[];

                  if (snapshot.hasError && !_hasShownLoadError) {
                    _hasShownLoadError = true;
                    final err = snapshot.error;
                    final msg = switch (err) {
                      TimeoutException() =>
                        'Server đang khởi động, thử lại sau vài giây',
                      UnauthorizedException() =>
                        'Vui lòng đăng nhập để xem danh sách chuyến đi',
                      ApiException() => err.message,
                      _ => 'Không tải được danh sách chuyến đi',
                    };
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      showTopToast(
                        context,
                        message: msg,
                        type: TopToastType.error,
                      );
                    });
                  }

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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              onJoinTripTap: () {
                                showJoinTripDialog(context).then((joined) {
                                  if (joined == true) {
                                    _refreshTrips();
                                  }
                                });
                              },
                              onCreateTripTap: () {
                                Navigator.of(context)
                                    .pushNamed('/create-trip')
                                    .then((_) => _refreshTrips());
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
                              activeTripCount: trips.length,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              onViewAllTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AllTripsScreen(),
                                  ),
                                );
                              },
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
                                      trips: trips,
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTripCards(
    BuildContext context, {
    required double maxHeight,
    required List<Trip> trips,
  }) {
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

    if (trips.isEmpty) {
      // Keep UX minimal: no extra empty-state components.
      return const SizedBox.shrink();
    }

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
                  Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.itinerary, arguments: trip);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
