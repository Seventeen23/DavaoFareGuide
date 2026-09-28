import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../data/models/route_stop.dart';

Future<RouteStop?> showStopPicker({
  required BuildContext context,
  required List<RouteStop> stops,
  required String title,
  RouteStop? selected,
}) {
  return showModalBottomSheet<RouteStop>(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.75,
    ),
    builder: (context) => _StopPickerSheet(
      stops: stops,
      title: title,
      selected: selected,
    ),
  );
}

class _StopPickerSheet extends StatefulWidget {
  const _StopPickerSheet({
    required this.stops,
    required this.title,
    this.selected,
  });

  final List<RouteStop> stops;
  final String title;
  final RouteStop? selected;

  @override
  State<_StopPickerSheet> createState() => _StopPickerSheetState();
}

class _StopPickerSheetState extends State<_StopPickerSheet> {
  late final TextEditingController _controller;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<RouteStop> get _filtered {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.stops;
    return widget.stops
        .where((stop) => stop.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final stops = _filtered;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xs,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _controller,
                  autofocus: false,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Search stops',
                    prefixIcon: const Icon(Icons.search_rounded, size: 21),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded, size: 19),
                            onPressed: () {
                              _controller.clear();
                              setState(() => _query = '');
                            },
                          ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.outline, height: 1),
          Flexible(
            child: stops.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: Text(
                      'No stops match your search.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    itemCount: stops.length,
                    itemBuilder: (context, index) {
                      final stop = stops[index];
                      final isSelected = widget.selected?.sequence == stop.sequence;

                      return ListTile(
                        onTap: () => Navigator.of(context).pop(stop),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: 2,
                        ),
                        leading: Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.brandSurface
                                : AppColors.background,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${stop.kmIndex}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.brand
                                  : AppColors.inkMuted,
                            ),
                          ),
                        ),
                        title: Text(
                          stop.name,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.brand,
                                size: 20,
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
