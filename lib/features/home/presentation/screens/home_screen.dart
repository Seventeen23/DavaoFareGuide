import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../data/models/geo.dart';
import '../../../../data/models/jeepney_route.dart';
import '../../../../data/providers/route_providers.dart';
import '../providers/route_search_provider.dart';
import '../widgets/landmark_tile.dart';
import '../widgets/route_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  bool _hasQuery = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setQuery(String value) {
    _searchController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    setState(() => _hasQuery = value.trim().isNotEmpty);
    ref.read(routeSearchQueryProvider.notifier).update(value);
  }

  @override
  Widget build(BuildContext context) {
    final routesAsync = ref.watch(filteredRoutesProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 232,
            backgroundColor: AppColors.brand,
            foregroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            systemOverlayStyle: AppTheme.overlayStyle,
            flexibleSpace: FlexibleSpaceBar(
              background: _HeaderBackground(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.sm,
                      AppSpacing.xl,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusSm,
                                ),
                              ),
                              child: const Icon(
                                Icons.directions_bus_filled_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Davao Jeepney',
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Know your fare\nbefore you ride.',
                          style: textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            height: 1.15,
                            fontSize: 25,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _SearchField(
                          controller: _searchController,
                          hasQuery: _hasQuery,
                          onChanged: (value) {
                            setState(() => _hasQuery = value.trim().isNotEmpty);
                            ref.read(routeSearchQueryProvider.notifier).update(value);
                          },
                          onClear: () => _setQuery(''),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _LandmarksSliver(
            hasQuery: _hasQuery,
            onSelectQuery: _setQuery,
          ),
          if (!_hasQuery) const _PopularRoutesSliver(),
          routesAsync.when(
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: AppEmptyView(
                icon: Icons.error_outline_rounded,
                title: 'Could not load routes',
                message: '$error',
              ),
            ),
            data: (routes) => _RouteSliverList(
              routes: routes,
              totalCount: ref.watch(routeListProvider).value?.length ?? routes.length,
              hasQuery: _hasQuery,
              onRouteTap: (route) => context.push(Routes.rideFor(route.codeName)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Landmarks are the third thing the home screen can answer, alongside routes
/// and the search box itself.
///
/// With a query it lists what matched, and tapping one narrows the route list
/// below to the routes passing through it. With no query it is just the way
/// into the browser, because the data has been seeded all along and a list of
/// 98 places with no ranking is not something to dump on the first screen.
class _LandmarksSliver extends ConsumerWidget {
  const _LandmarksSliver({required this.hasQuery, required this.onSelectQuery});

  final bool hasQuery;
  final ValueChanged<String> onSelectQuery;

  /// Enough to see whether the search landed, without pushing the route list
  /// off the screen.
  static const int _maxResults = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final landmarksAsync = ref.watch(landmarkListProvider);
    final matchesAsync = ref.watch(landmarkMatchesProvider);
    final textTheme = Theme.of(context).textTheme;

    return landmarksAsync.when(
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
      data: (landmarks) {
        if (landmarks.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        if (!hasQuery) return _browseCard(context, landmarks.length);

        final matches = matchesAsync.value ?? const [];
        if (matches.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final shown = matches.take(_maxResults).toList();
        final linkedShown =
            shown.where((landmark) => landmark.isLinked).length;

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      size: 17,
                      color: AppColors.brand,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Landmarks',
                      style: textTheme.titleSmall,
                    ),
                    const Spacer(),
                    Text(
                      '${matches.length} match${matches.length == 1 ? '' : 'es'}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  linkedShown == 0
                      ? 'None of these are on a mapped route yet.'
                      : 'Tap one to see the routes that pass it.',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                for (var i = 0; i < shown.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  LandmarkTile(
                    landmark: shown[i],
                    onTap: () => _select(context, shown[i]),
                  ),
                ],
                if (matches.length > shown.length) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _TextAction(
                    label: 'See all ${matches.length} landmarks',
                    onTap: () => context.push(Routes.landmarks),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Tapping a landmark turns it into the query, so the route list underneath
  /// becomes the answer to "which routes pass through here". That is the whole
  /// point of seeding the landmark-to-route links. Refreshing the parent's
  /// query (not just the provider) keeps the search box and the browse card in
  /// step with the filtered list.
  void _select(BuildContext context, MapLandmark landmark) {
    if (!landmark.isLinked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No jeepney route serves ${landmark.name} yet.'),
        ),
      );
      return;
    }
    onSelectQuery(landmark.name);
  }

  Widget _browseCard(BuildContext context, int count) {
    final textTheme = Theme.of(context).textTheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.sm,
        ),
        child: AppCard(
          onTap: () => context.push(Routes.landmarks),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.brandSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(
                  Icons.place_rounded,
                  color: AppColors.brand,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Browse landmarks', style: textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      'Find a place, see the routes that pass it',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.inkMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          minimumSize: const Size(0, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.brand,
          ),
        ),
      ),
    );
  }
}

/// "Most popular" is derived from the routes this user has actually priced a
/// ride on, via [popularRoutesProvider]. There is no curated list, so the
/// section stays hidden until real usage exists.
class _PopularRoutesSliver extends ConsumerWidget {
  const _PopularRoutesSliver();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularAsync = ref.watch(popularRoutesProvider);
    final textTheme = Theme.of(context).textTheme;

    return popularAsync.maybeWhen(
      data: (routes) {
        if (routes.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.insights_rounded,
                      size: 17,
                      color: AppColors.brand,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Most popular routes', style: textTheme.titleSmall),
                    const Spacer(),
                    Text('by your rides', style: textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                for (var i = 0; i < routes.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  _PopularRouteCard(
                    rank: i + 1,
                    route: routes[i],
                    onTap: () =>
                        context.push(Routes.rideFor(routes[i].codeName)),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}

class _PopularRouteCard extends StatelessWidget {
  const _PopularRouteCard({
    required this.rank,
    required this.route,
    required this.onTap,
  });

  final int rank;
  final JeepneyRoute route;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rank == 1 ? AppColors.brand : AppColors.brandSurface,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$rank',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: rank == 1 ? Colors.white : AppColors.brand,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall,
                ),
                const SizedBox(height: 1),
                Text(
                  '${route.stopCount} stops  ·  ${route.totalKm} km',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.inkMuted,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _RouteSliverList extends StatelessWidget {
  const _RouteSliverList({
    required this.routes,
    required this.totalCount,
    required this.hasQuery,
    required this.onRouteTap,
  });

  final List<JeepneyRoute> routes;
  final int totalCount;
  final bool hasQuery;
  final ValueChanged<JeepneyRoute> onRouteTap;

  @override
  Widget build(BuildContext context) {
    if (routes.isEmpty) {
      // An empty list with no query is not a search miss. It means the bundled
      // data is not there, and telling the user to try a different landmark
      // sends them looking for a problem they do not have.
      return SliverFillRemaining(
        hasScrollBody: false,
        child: hasQuery
            ? const AppEmptyView(
                title: 'No matching routes',
                message: 'Try a different destination or landmark.',
              )
            : const AppEmptyView(
                icon: Icons.error_outline_rounded,
                title: 'No routes available',
                message: 'The bundled route data could not be loaded. '
                    'Try restarting the app.',
              ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      sliver: SliverList.separated(
        itemCount: routes.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                totalCount == routes.length
                    ? '$totalCount routes available'
                    : '${routes.length} of $totalCount routes',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }
          final route = routes[index - 1];
          return RouteTile(route: route, onTap: () => onRouteTap(route));
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hasQuery,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool hasQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: 'Search a route or landmark',
        fillColor: Colors.white,
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.brand,
          size: 22,
        ),
        suffixIcon: hasQuery
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color: AppColors.inkMuted,
                onPressed: onClear,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.brandLight, AppColors.brand, AppColors.brandDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -70,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -90,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
