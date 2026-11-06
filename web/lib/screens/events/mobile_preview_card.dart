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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            offset: Offset(0, 10),
            blurRadius: 24,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mobile Simulated Status Bar
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
                      SizedBox(width: 4),
                      Icon(Icons.battery_full, size: 14),
                    ],
                  ),
                ],
              ),
            ),

            // Event Header Cover
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
                      AppStatusBadge(
                        label: registrationMode == 'free'
                            ? 'Tham gia tự do'
                            : 'Yêu cầu đăng ký',
                        variant: registrationMode == 'free'
                            ? AppBadgeVariant.info
                            : AppBadgeVariant.warning,
                      ),
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.share, size: 14, color: Colors.white),
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

            // Body Info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Club & Topic
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
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),

                  // Location
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

                  // Time
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        '${startsAt.day}/${startsAt.month}/${startsAt.year} • ${startsAt.hour}:${startsAt.minute.toString().padLeft(2, '0')}',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),

                  // Capacity Progress
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
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 0.0,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                  ],

                  // Description snippet
                  Text(
                    description.isEmpty
                        ? 'Mô tả chi tiết sự kiện sẽ hiển thị tại đây...'
                        : description,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  // Simulated CTA Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
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
