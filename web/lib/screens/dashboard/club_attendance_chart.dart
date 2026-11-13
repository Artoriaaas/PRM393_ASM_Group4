import 'dart:math';
import 'package:flutter/material.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../../viewmodels/dashboard_viewmodel.dart';

class ClubAttendanceChart extends StatelessWidget {
  const ClubAttendanceChart({
    super.key,
    required this.metrics,
  });

  final List<EventAttendanceMetrics> metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'Chưa có dữ liệu sự kiện để vẽ biểu đồ.',
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final maxVal = metrics.fold<int>(
      10,
      (prev, m) =>
          max(prev, max(m.capacity, max(m.approvedCount, m.checkedInCount))),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.s16,
          runSpacing: AppSpacing.s8,
          children: [
            _buildLegendItem(
              color: AppColors.info,
              icon: Icons.people_outline,
              label: 'Sức chứa (capacity)',
            ),
            _buildLegendItem(
              color: AppColors.primary,
              icon: Icons.how_to_reg_outlined,
              label: 'Đã duyệt (activeCount)',
            ),
            _buildLegendItem(
              color: AppColors.success,
              icon: Icons.fact_check_outlined,
              label: 'Đã điểm danh (check-in)',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s20),
        SizedBox(
          height: 220,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 160,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$maxVal', style: AppTypography.textTheme.labelSmall),
                        Text(
                          '${(maxVal / 2).round()}',
                          style: AppTypography.textTheme.labelSmall,
                        ),
                        Text('0', style: AppTypography.textTheme.labelSmall),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  const SizedBox(height: 1),
                  const SizedBox(height: AppSpacing.s8),
                  const SizedBox(height: 38),
                ],
              ),
              const SizedBox(width: AppSpacing.s12),
              const VerticalDivider(width: 1, color: AppColors.border),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: metrics.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppSpacing.s32),
                  itemBuilder: (context, index) {
                    final item = metrics[index];
                    return _buildEventBarGroup(context, item, maxVal);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.borderR6,
          ),
          child: Icon(icon, size: 11, color: AppColors.onPrimary),
        ),
        const SizedBox(width: AppSpacing.s8),
        Text(
          label,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEventBarGroup(
    BuildContext context,
    EventAttendanceMetrics item,
    int maxVal,
  ) {
    const double chartHeight = 160.0;
    final capHeight = (item.capacity / maxVal) * chartHeight;
    final appHeight = (item.approvedCount / maxVal) * chartHeight;
    final chkHeight = (item.checkedInCount / maxVal) * chartHeight;

    return Semantics(
      container: true,
      label:
          'Sự kiện ${item.eventTitle}: Sức chứa ${item.capacity}, Đã duyệt ${item.approvedCount}, Đã điểm danh ${item.checkedInCount}',
      child: SizedBox(
        width: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: chartHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar(
                    capHeight,
                    AppColors.info,
                    'Sức chứa: ${item.capacity}',
                  ),
                  const SizedBox(width: AppSpacing.s4),
                  _buildBar(
                    appHeight,
                    AppColors.primary,
                    'Đã duyệt: ${item.approvedCount}',
                  ),
                  const SizedBox(width: AppSpacing.s4),
                  _buildBar(
                    chkHeight,
                    AppColors.success,
                    'Đã điểm danh: ${item.checkedInCount}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppSpacing.s8),
            SizedBox(
              height: 38,
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  item.eventTitle,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(double height, Color color, String tooltip) {
    final barHeight = height.clamp(4.0, 160.0);
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 18,
        height: barHeight,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.r6),
          ),
        ),
      ),
    );
  }
}
