import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eventhub_core/eventhub_core.dart';

class WorkshopCover extends StatelessWidget {
  const WorkshopCover({super.key, this.free = false});
  final bool free;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: AppRadius.borderR16,
    child: AspectRatio(
      aspectRatio: 2,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: 328,
          height: 164,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFA93612), Color(0xFFF47A3B)],
              ),
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                const Positioned(
                  left: 198,
                  top: -64,
                  child: SizedBox(
                    width: 190,
                    height: 190,
                    child: _CoverIcon('cover_orbit', size: 190),
                  ),
                ),
                const Positioned(
                  left: -34,
                  top: 92,
                  child: SizedBox(
                    width: 112,
                    height: 112,
                    child: _CoverIcon('cover_corner', size: 112),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.borderFull,
                    ),
                    child: Text(
                      free ? 'ÂM NHẠC' : 'UX WORKSHOP',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA93612),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 60,
                  child: Text(
                    free ? 'ACOUSTIC\nCAMPUS' : 'THIẾT KẾ\nTRẢI NGHIỆM',
                    style: const TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 22,
                      height: 28 / 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.surface,
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 126,
                  child: Text(
                    free
                        ? 'Live music  •  Campus'
                        : 'Research  •  Prototype  •  Test',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFFE9DE),
                    ),
                  ),
                ),
                if (!free) ...[
                  Positioned(
                    left: 238,
                    top: 24,
                    child: Container(
                      width: 76,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.borderR12,
                      ),
                    ),
                  ),
                  for (final r in [
                    (43.0, 12.0, Color(0xFFFFD3BE)),
                    (64.0, 34.0, Color(0xFFFFF1EA)),
                    (106.0, 24.0, Color(0xFFFFE3D5)),
                  ])
                    Positioned(
                      left: 250,
                      top: r.$1,
                      child: Container(
                        width: 52,
                        height: r.$2,
                        decoration: BoxDecoration(
                          color: r.$3,
                          borderRadius: AppRadius.borderR6,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _CoverIcon extends StatelessWidget {
  const _CoverIcon(this.name, {this.size = 24});
  final String name;
  final double size;
  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/icons/$name.svg', width: size, height: size);
}
