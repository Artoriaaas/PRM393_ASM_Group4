import 'package:flutter/material.dart';
import 'package:eventhub_core/eventhub_core.dart';

class MobilePreviewCard extends StatelessWidget {
  const MobilePreviewCard({
    super.key,
    required this.title,
    required this.clubName,
    required this.location,
    required this.startsAt,
    required this.endsAt,
    required this.deadline,
    required this.registrationMode,
    required this.capacity,
    required this.description,
    required this.topic,
    required this.audience,
    required this.preparation,
    required this.activities,
  });

  final String title;
  final String clubName;
  final String location;
  final DateTime startsAt;
  final DateTime endsAt;
  final DateTime? deadline;
  final String registrationMode;
  final int capacity;
  final String description;
  final String topic;
  final String audience;
  final String preparation;
  final List<String> activities;

  String _formatDateTime(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year} • $hh:$min';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderR24,
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: AppShadows.elevation2,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.borderR24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s8,
              ),
              color: AppColors.surfaceSubtle,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '9:41',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Row(
                    children: [
                      Icon(Icons.wifi, size: 14),
                      SizedBox(width: AppSpacing.s4),
                      Icon(Icons.battery_full, size: 14),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 140,
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.coverStart, AppColors.coverEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: AppStatusBadge(
                          label: registrationMode == 'free'
                              ? 'Tham gia tự do'
                              : 'Yêu cầu đăng ký',
                          variant: registrationMode == 'free'
                              ? AppBadgeVariant.info
                              : AppBadgeVariant.warning,
                          icon: Icon(
                            registrationMode == 'free'
                                ? Icons.lock_open_outlined
                                : Icons.how_to_reg_outlined,
                          ),
                        ),
                      ),
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.onPrimary.withValues(
                          alpha: 0.24,
                        ),
                        child: const Icon(
                          Icons.share,
                          size: 14,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    title.isEmpty ? 'Tiêu đề sự kiện...' : title,
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.groups,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: Text(
                          clubName.isEmpty ? 'Câu lạc bộ tổ chức' : clubName,
                          style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (topic.isNotEmpty) ...[
                        const SizedBox(width: AppSpacing.s8),
                        AppStatusBadge(
                          label: topic,
                          variant: AppBadgeVariant.neutral,
                          icon: const Icon(Icons.sell_outlined),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: Text(
                          location.isEmpty ? 'Địa điểm tổ chức' : location,
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: Text(
                          _formatDateTime(startsAt),
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (registrationMode != 'free' && deadline != null) ...[
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      'Hạn đăng ký: ${_formatDateTime(deadline!)}',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s12),
                  if (registrationMode != 'free') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sức chứa:',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '$capacity chỗ',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    ClipRRect(
                      borderRadius: AppRadius.borderR6,
                      child: const LinearProgressIndicator(
                        value: 0.0,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                  ],
                  Text(
                    description.isEmpty
                        ? 'Mô tả chi tiết sự kiện sẽ hiển thị tại đây...'
                        : description,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (activities.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      'Hoạt động (${activities.length}): ${activities.join(" • ")}',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.borderR8,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      registrationMode == 'free'
                          ? 'Tham gia tự do'
                          : 'Đăng ký tham gia ngay',
                      style: AppTypography.textTheme.labelLarge?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
