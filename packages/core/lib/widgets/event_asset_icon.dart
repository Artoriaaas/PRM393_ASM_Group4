import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EventAssetIcon extends StatelessWidget {
  const EventAssetIcon(this.name, {super.key, this.color, this.size = 24});
  final String name;
  final Color? color;
  final double size;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'packages/eventhub_core/assets/icons/$name.svg',
    width: size,
    height: size,
    colorFilter: color == null
        ? null
        : ColorFilter.mode(color!, BlendMode.srcIn),
  );
}
