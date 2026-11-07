import 'package:flutter/material.dart';

import '../theme/app_touch_targets.dart';

class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });
  final Widget label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: AppTouchTargets.minConstraints,
    child: ChoiceChip(
      label: label,
      selected: selected,
      onSelected: onSelected,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    ),
  );
}
