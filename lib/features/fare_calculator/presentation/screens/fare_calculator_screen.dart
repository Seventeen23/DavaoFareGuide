import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/fare_calculator.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/trip_distance.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../data/models/jeepney_route.dart';
import '../../../../data/models/passenger_category.dart';
import '../../../../data/models/route_stop.dart';
import '../../../../data/providers/route_providers.dart';
import '../../../home/presentation/widgets/route_timeline.dart';
import '../models/fare_estimate.dart';
import '../providers/fare_estimate_provider.dart';
import '../widgets/fare_estimate_card.dart';
import '../widgets/location_selector.dart';
import '../widgets/route_diagram.dart';
import '../widgets/stop_picker_sheet.dart';

class FareCalculatorScreen extends ConsumerWidget {
  const FareCalculatorScreen({super.key, required this.codeName});

  final String codeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeAsync = ref.watch(routeDetailProvider(codeName));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan your ride'),
        systemOverlayStyle: AppTheme.overlayStyle,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: routeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppEmptyView(
          icon: Icons.error_outline_rounded,
          title: 'Could not load route',
          message: '$error',
        ),
        data: (route) => _BookingBody(route: route),
      ),
    );
  }
}

class _BookingBody extends ConsumerWidget {
  const _BookingBody({required this.route});

  final JeepneyRoute route;

  Future<void> _pick({
    required BuildContext context,
    required WidgetRef ref,
    required bool isOrigin,
  }) async {
    final selection = ref.read(fareSelectionProvider(route.codeName));
    final stop = await showStopPicker(
      context: context,
      stops: route.stopsInOrder,
      title: isOrigin ? 'Where do you board?' : 'Where do you get off?',
      selected: isOrigin ? selection.origin : selection.destination,
    );
    if (stop == null) {
      debugPrint('[PICK] isOrigin=$isOrigin -> dismissed, no stop');
      return;
    }

    debugPrint('[PICK] isOrigin=$isOrigin -> got stop ${stop.name}');
    final notifier = ref.read(fareSelectionProvider(route.codeName).notifier);
    if (isOrigin) {
      notifier.setOrigin(stop);
    } else {
      notifier.setDestination(stop);
    }
    debugPrint('[PICK] state now: ${ref.read(fareSelectionProvider(route.codeName))}');
  }

  /// Tapping a node on the diagram walks the selection forward: boarding
  /// first, then drop-off, then each further tap shifts the window along the
  /// route. Identical origin and destination is rejected because it would
  /// produce a meaningless zero fare.
  void _applyStopTap(RouteStop stop, WidgetRef ref) {
    final selection = ref.read(fareSelectionProvider(route.codeName));
    final notifier = ref.read(fareSelectionProvider(route.codeName).notifier);

    if (selection.origin == null) {
      notifier.setOrigin(stop);
      return;
    }

    if (selection.destination == null) {
      if (stop.sequence == selection.origin!.sequence) return;
      notifier.setDestination(stop);
      return;
    }

    notifier.setOrigin(selection.destination!);
    if (stop.sequence == selection.destination!.sequence) {
      notifier.clearDestination();
    } else {
      notifier.setDestination(stop);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(fareSelectionProvider(route.codeName));
    final estimate = ref.watch(fareEstimateProvider(route.codeName));
    final notifier = ref.read(fareSelectionProvider(route.codeName).notifier);
    final textTheme = Theme.of(context).textTheme;
    final stops = route.stopsInOrder;

    // A route counts as used the moment both stops are chosen, which is the
    // same point the fare becomes calculable.
    ref.listen(fareSelectionProvider(route.codeName), (previous, next) {
      if (next.isComplete && !(previous?.isComplete ?? false)) {
        recordRouteUsage(ref, route.codeName);
      }
    });

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xxl,
            ),
            children: [
              _RouteHeader(route: route),
              const SizedBox(height: AppSpacing.lg),
              LocationSelector(
                origin: selection.origin,
                destination: selection.destination,
                onPickOrigin: () =>
                    _pick(context: context, ref: ref, isOrigin: true),
                onPickDestination: () =>
                    _pick(context: context, ref: ref, isOrigin: false),
                onSwap: notifier.swap,
              ),
              const SizedBox(height: AppSpacing.lg),
              FareEstimateCard(estimate: estimate ?? _emptyEstimate),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Text('Route diagram', style: textTheme.titleMedium),
                  const Spacer(),
                  Text('${stops.length} total', style: textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Tap a stop on the diagram to set it as your boarding or drop-off point.',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: RouteDiagram(
                  stops: stops,
                  origin: selection.origin,
                  destination: selection.destination,
                  onStopTap: (stop) => _applyStopTap(stop, ref),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Text('Stops along the way', style: textTheme.titleMedium),
                  const Spacer(),
                  Text('${stops.length} total', style: textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: RouteTimeline(
                  stops: stops,
                  highlightFrom: selection.origin,
                  highlightTo: selection.destination,
                ),
              ),
            ],
          ),
        ),
        _BottomBar(estimate: estimate),
      ],
    );
  }

  FareEstimate get _emptyEstimate => FareEstimate(
    regular: FareBreakdown(
      distance: TripDistance.precise(0),
      billableKm: 0,
      baseFare: Money.zero,
      distanceCharge: Money.zero,
      deduction: Money.zero,
      total: Money.zero,
      category: PassengerCategory.regular,
    ),
    discounted: FareBreakdown(
      distance: TripDistance.precise(0),
      billableKm: 0,
      baseFare: Money.zero,
      distanceCharge: Money.zero,
      deduction: Money.zero,
      total: Money.zero,
      category: PassengerCategory.student,
    ),
    fareRules: const FareRules(),
  );
}

class _RouteHeader extends StatelessWidget {
  const _RouteHeader({required this.route});

  final JeepneyRoute route;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(route.displayName, style: textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(route.viaLabels.join('  •  '), style: textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.brandSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            children: [
              Text(
                '${route.totalKm}',
                style: textTheme.titleMedium?.copyWith(color: AppColors.brand),
              ),
              Text(
                'KM',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.brand,
                  fontSize: 9.5,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.estimate});

  final FareEstimate? estimate;

  @override
  Widget build(BuildContext context) {
    final ready = estimate != null && !estimate!.isIdenticalStops;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
        boxShadow: [
          BoxShadow(color: Color(0x0F0F1A16), blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: FilledButton.icon(
            onPressed: ready
                ? () {
                    HapticFeedback.mediumImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Trip history lands in a future release.'),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
            label: Text(
              ready
                  ? 'Confirm trip  ·  ₱${estimate!.discounted.total.pesos.toStringAsFixed(2)}'
                  : 'Select two stops',
            ),
          ),
        ),
      ),
    );
  }
}
