import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:eventhub_core/eventhub_core.dart';

/// Read-only A04 preview. Values come from the editor, never a saved mock event.
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
    this.coverKey = '',
    this.coverUrl = '',
    this.activeCount = 0,
  });
  final String title,
      clubName,
      location,
      registrationMode,
      description,
      topic,
      audience,
      preparation;
  final DateTime startsAt, endsAt;
  final DateTime? deadline;
  final int capacity, activeCount;
  final List<String> activities;
  final String coverKey, coverUrl;

  bool get _free => registrationMode == 'free';

  @override
  Widget build(BuildContext context) => Container(
    width: 360,
    height: 800,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('9:41', style: AppTypography.textTheme.labelSmall),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Chi tiết sự kiện',
                    style: AppTypography.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              key: const ValueKey('mobile-preview-content'),
              padding: const EdgeInsets.all(16),
              children: [
                ClipRRect(
                  borderRadius: AppRadius.borderR16,
                  child: AspectRatio(aspectRatio: 2, child: _cover(context)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: AppStatusBadge(
                        label: _free ? 'Tham gia tự do' : 'Cần đăng ký',
                        variant: AppBadgeVariant.warning,
                      ),
                    ),
                    if (!_free)
                      Flexible(
                        child: AppStatusBadge(
                          label:
                              'Còn ${(capacity - activeCount).clamp(0, capacity < 0 ? 0 : capacity)} chỗ',
                          variant: AppBadgeVariant.success,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title.isEmpty ? 'Tiêu đề sự kiện' : title,
                  style: AppTypography.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  clubName.isEmpty ? 'Câu lạc bộ tổ chức' : clubName,
                  style: const TextStyle(color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: AppRadius.borderR16,
                  ),
                  child: Column(
                    children: [
                      _fact(
                        Icons.calendar_today_outlined,
                        'Thời gian diễn ra',
                        '${eventTime(startsAt)}–${eventTime(endsAt)} · ${eventDate(startsAt)}',
                      ),
                      const SizedBox(height: 16),
                      _fact(
                        Icons.location_on_outlined,
                        'Địa điểm',
                        location.isEmpty ? 'Địa điểm tổ chức' : location,
                      ),
                      if (!_free && deadline != null) ...[
                        const SizedBox(height: 16),
                        _fact(
                          Icons.schedule,
                          'Hạn đăng ký',
                          '${eventTime(deadline!)} · ${eventDate(deadline!)}',
                        ),
                      ],
                    ],
                  ),
                ),
                if (_free) ...[
                  const SizedBox(height: 16),
                  _panel(
                    'Không cần đăng ký. Đến trực tiếp theo thời gian và địa điểm công bố. Không có điểm danh QR trên app.',
                  ),
                ],
                const SizedBox(height: 16),
                Text('Giới thiệu', style: AppTypography.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  description.isEmpty
                      ? 'Mô tả chi tiết sự kiện sẽ hiển thị tại đây.'
                      : description,
                ),
                const SizedBox(height: 16),
                Text(
                  'Bạn sẽ làm gì?',
                  style: AppTypography.textTheme.titleMedium,
                ),
                for (final activity in activities)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('• $activity'),
                  ),
                if (audience.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Dành cho ai?',
                    style: AppTypography.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(audience),
                ],
                if (preparation.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Cần chuẩn bị',
                    style: AppTypography.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(preparation),
                ],
              ],
            ),
          ),
          if (!_free)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: ExcludeSemantics(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.borderR12,
                  ),
                  child: Text(
                    'Đăng ký sự kiện',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );

  Widget _panel(String text) => Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: AppColors.surfaceSubtle,
      borderRadius: AppRadius.borderR16,
    ),
    child: Text(text),
  );

  Widget _fact(IconData icon, String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.brandSubtle,
          borderRadius: AppRadius.borderR12,
        ),
        child: Icon(icon, size: 22),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(value),
          ],
        ),
      ),
    ],
  );

  Widget _cover(BuildContext context) {
    final url = coverUrl.trim();
    if (url.startsWith('data:image')) {
      try {
        return Image.memory(
          base64Decode(url.substring(url.indexOf(',') + 1)),
          fit: BoxFit.cover,
          semanticLabel: 'Ảnh bìa $title',
          errorBuilder: (_, _, _) => _fallbackCover(),
        );
      } catch (_) {
        return _fallbackCover();
      }
    }
    if (Uri.tryParse(url)?.scheme == 'https') {
      return Image.network(
        url,
        fit: BoxFit.cover,
        semanticLabel: 'Ảnh bìa $title',
        errorBuilder: (_, _, _) => _fallbackCover(),
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator()),
      );
    }
    return _fallbackCover();
  }

  Widget _fallbackCover() => Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.coverStart, AppColors.coverEnd],
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                topic.isEmpty ? 'SỰ KIỆN' : topic.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  title.isEmpty ? 'Tiêu đề sự kiện' : title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Icon(
          Icons.calendar_today_outlined,
          color: AppColors.onPrimary,
          size: 40,
        ),
      ],
    ),
  );
}
