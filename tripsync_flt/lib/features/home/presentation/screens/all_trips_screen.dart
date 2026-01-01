import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/auth_token_store.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/widgets/top_toast.dart';
import '../widgets/all_trips_header.dart';
import '../widgets/all_trips_search_bar.dart';
import '../widgets/trip_card.dart';
import '../../../trip/data/datasources/trip_remote_data_source.dart';
import '../../../trip/data/repositories/trip_repository_impl.dart';
import '../../../trip/domain/entities/trip.dart';
import '../../../trip/domain/repositories/trip_repository.dart';
import '../../../trip/presentation/services/trip_list_loader.dart';
import '../../../itinerary/presentation/screens/itinerary_screen.dart';

class AllTripsScreen extends StatefulWidget {
  const AllTripsScreen({super.key});

  @override
  State<AllTripsScreen> createState() => _AllTripsScreenState();
}

class _AllTripsScreenState extends State<AllTripsScreen> {
  late final TripRepository _tripRepository;
  late Future<List<Trip>> _tripsFuture;
  bool _hasShownLoadError = false;
  String _query = '';

  Future<bool> _confirmAndDeleteTrip(Trip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final shape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        );
        return AlertDialog(
          title: const Text('Xóa chuyến đi?'),
          content: Text('Bạn có chắc muốn xóa "${trip.title}" không?'),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: shape,
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        shape: shape,
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Xóa'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirmed != true) return false;
    if (!mounted) return false;

    final tripId = trip.id;
    if (tripId == null) {
      if (mounted) {
        showTopToast(
          context,
          message: 'Không thể xóa chuyến đi (thiếu trip_id)',
          type: TopToastType.error,
        );
      }
      return false;
    }

    try {
      await _tripRepository.deleteTrip(tripId: tripId);

      if (mounted) {
        showTopToast(
          context,
          message: 'Xóa chuyến đi thành công',
          type: TopToastType.success,
        );
      }
      return true;
    } catch (err) {
      final msg = switch (err) {
        TimeoutException() => 'Server đang khởi động, thử lại sau vài giây',
        UnauthorizedException() => 'Vui lòng đăng nhập để xóa chuyến đi',
        ApiException() => err.message,
        _ => 'Không xóa được chuyến đi',
      };
      if (mounted) {
        showTopToast(context, message: msg, type: TopToastType.error);
      }
      return false;
    }
  }

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

  List<Trip> _filterTrips(List<Trip> trips) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return trips;
    return trips.where((t) {
      return t.title.toLowerCase().contains(q) ||
          t.location.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4, bottom: 8),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Material(
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pop(context),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Header Section
            AllTripsHeader(
              onCreateTripTap: () {
                Navigator.pushNamed(
                  context,
                  '/create-trip',
                ).then((_) => _refreshTrips());
              },
            ),

            const SizedBox(height: 12),

            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: AllTripsSearchBar(
                onSearchChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // Trip List
            Expanded(
              child: FutureBuilder<List<Trip>>(
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

                  final visibleTrips = _filterTrips(trips);

                  if (snapshot.connectionState == ConnectionState.waiting &&
                      trips.isEmpty) {
                    return const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  if (visibleTrips.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(overscroll: false),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: visibleTrips.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final trip = visibleTrips[index];

                        final card = TripCard(
                          title: trip.title,
                          location: trip.location,
                          imageUrl: trip.imageUrl,
                          memberCount: trip.memberCount,
                          memberAvatarUrls: trip.memberAvatarUrls,
                          memberColors: trip.memberColors
                              .map(
                                (color) => Color(
                                  int.parse(color.replaceFirst('#', '0xFF')),
                                ),
                              )
                              .toList(),
                          cardWidth: double.infinity,
                          imageHeight: 235,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TripItineraryScreen(trip: trip),
                              ),
                            );
                          },
                        );

                        final tripId = trip.id;
                        if (tripId == null) return card;

                        const outerRadius = 24.0;

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(outerRadius),
                          child: Dismissible(
                            key: ValueKey<int>(tripId),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              if (direction != DismissDirection.endToStart) {
                                return false;
                              }
                              final deleted = await _confirmAndDeleteTrip(trip);
                              if (deleted && mounted) {
                                _refreshTrips();
                              }
                              // Keep the widget in the tree; it will disappear after refresh.
                              return false;
                            },
                            background: Container(
                              color: AppColors.primary,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: card,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
