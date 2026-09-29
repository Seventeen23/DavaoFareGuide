import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../data/models/geo.dart';
import '../../../../data/models/jeepney_route.dart';
import '../../../../data/providers/route_providers.dart';
import '../widgets/landmark_tile.dart';
import '../widgets/route_tile.dart';

/// Browses every landmark in the bundle.
///
/// The data was always seeded and reachable; this is the screen that finally
/// reads it, which is why a geo-layer build looked unchanged until now.
class LandmarksScreen extends ConsumerStatefulWidget {
  const LandmarksScreen({super.key});

  @override
  ConsumerState<LandmarksScreen> createState() => _LandmarksScreenState();
}

class _LandmarksScreenState extends ConsumerState<LandmarksScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _category;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final landmarksAsync = ref.watch(landmarkListProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Landmarks'),
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        systemOverlayStyle: AppTheme.overlayStyle,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Search a landmark',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.brand,
                  size: 22,
                ),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        color: AppColors.inkMuted,
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          landmarksAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (error, _) => const SizedBox.shrink(),
            data: (landmarks) => _CategoryFilterBar(
              landmarks: landmarks,
              selected: _category,
              onSelected: (category) => setState(() {
                _category = category == _category ? null : category;
              }),
            ),
          ),
          Expanded(
            child: landmarksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => AppEmptyView(
                icon: Icons.error_outline_rounded,
                title: 'Could not load landmarks',
                message: '$error',
              ),
              data: (landmarks) {
                final visible = _visible(landmarks);
                if (visible.isEmpty) {
                  return AppEmptyView(
                    title: 'No matching landmarks',
                    message: 'Try a different name or category.',
                  );
                }

                final linked = visible.where((l) => l.isLinked).length;

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.sm,
                    AppSpacing.xl,
                    AppSpacing.xxl,
                  ),
                  itemCount: visible.length + 1,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          '$linked of ${visible.length} on a route',
                          style: textTheme.bodySmall,
                        ),
                      );
                    }
                    final landmark = visible[index - 1];
                    return LandmarkTile(
                      landmark: landmark,
                      onTap: () => _showRoutes(landmark),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<MapLandmark> _visible(List<MapLandmark> landmarks) {
    final filtered = landmarks
        .where(
          (landmark) =>
              (_category == null || landmark.category == _category) &&
              landmark.matches(_query),
        )
        .toList();
    // Linked places first: they are the ones the user can actually act on, and
    // the 24 unlinked ones are still reachable by scrolling.
    filtered.sort((a, b) {
      if (a.isLinked != b.isLinked) return a.isLinked ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return filtered;
  }

  Future<void> _showRoutes(MapLandmark landmark) async {
    // Await the routes rather than reading `.value`: a tap can land before the
    // provider has resolved, and an empty list there would tell the user no
    // route serves a place that plenty of routes serve.
    List<JeepneyRoute> routes;
    try {
      routes = await ref.read(routeListProvider.future);
    } on Object {
      routes = const <JeepneyRoute>[];
    }
    final byCodeName = {for (final route in routes) route.codeName: route};
    final serving = <JeepneyRoute>[
      for (final codeName in landmark.routeCodes) ?byCodeName[codeName],
    ];

    if (serving.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No jeepney route serves ${landmark.name} yet.'),
        ),
      );
      return;
    }

    if (!mounted) return;
    final chosen = await showModalBottomSheet<JeepneyRoute>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      builder: (context) => _RoutesSheet(landmark: landmark, routes: serving),
    );

    if (chosen != null && mounted) {
      context.push(Routes.rideFor(chosen.codeName));
    }
  }
}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.landmarks,
    required this.selected,
    required this.onSelected,
  });

  final List<MapLandmark> landmarks;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final categories = landmarks.map((l) => l.category).toSet().toList()
      ..sort((a, b) => landmarkCategoryLabel(a).compareTo(landmarkCategoryLabel(b)));

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;
          return Center(
            child: ChoiceChip(
              label: Text(landmarkCategoryLabel(category)),
              selected: isSelected,
              onSelected: (_) => onSelected(category),
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.ink,
              ),
              selectedColor: AppColors.brand,
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: isSelected ? AppColors.brand : AppColors.outline,
              ),
              shape: const StadiumBorder(),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}

class _RoutesSheet extends StatelessWidget {
  const _RoutesSheet({required this.landmark, required this.routes});

  final MapLandmark landmark;
  final List<JeepneyRoute> routes;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Icon(
                  landmarkCategoryIcon(landmark.category),
                  color: AppColors.brand,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    landmark.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              routes.length == 1
                  ? '1 route passes through here'
                  : '${routes.length} routes pass through here',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: routes.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) => RouteTile(
                  route: routes[index],
                  onTap: () => Navigator.of(context).pop(routes[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
