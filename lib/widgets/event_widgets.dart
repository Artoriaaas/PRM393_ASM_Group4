import '../utils/event_formatters.dart';
export '../utils/event_formatters.dart';
import 'workshop_cover.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/event.dart';
import '../theme/theme.dart';
import 'widgets.dart';

class EventPanel extends StatelessWidget {
  const EventPanel({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.s16),
    decoration: const BoxDecoration(
      color: AppColors.surfaceSubtle,
      borderRadius: AppRadius.borderR16,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final child in children)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s8),
            child: child,
          ),
      ],
    ),
  );
}

class GenericEventCover extends StatelessWidget {
  const GenericEventCover(this.event, {super.key});
  final Event event;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 164),
    padding: const EdgeInsets.all(18),
    decoration: const BoxDecoration(
      borderRadius: AppRadius.borderR16,
      gradient: LinearGradient(
        colors: [AppColors.coverStart, AppColors.coverEnd],
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.topic.isEmpty ? 'SỰ KIỆN' : event.topic.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                event.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.s12),
        SvgPicture.asset(
          'assets/icons/event_calendar.svg',
          width: AppSpacing.s40,
          height: AppSpacing.s40,
          colorFilter: const ColorFilter.mode(
            AppColors.onPrimary,
            BlendMode.srcIn,
          ),
        ),
      ],
    ),
  );
}

class EventSummary extends StatelessWidget {
  const EventSummary(this.event, {super.key, this.cover = false});
  final Event event;
  final bool cover;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (cover) ...[
        if (RegExp(r'^[a-z0-9-]+$').hasMatch(event.coverKey) &&
            [
              'ux-design',
              'acoustic-live',
              'badminton',
              'green-campus',
              'career-connect',
            ].contains(event.coverKey))
          ClipRRect(
            borderRadius: AppRadius.borderR16,
            child: AspectRatio(
              aspectRatio: 2,
              child: Image.asset(
                'assets/event-covers/${event.coverKey == 'acoustic-live' ? 'acoustic' : event.coverKey}.jpg',
                fit: BoxFit.cover,
                semanticLabel: 'Ảnh bìa ${event.title}',
              ),
            ),
          )
        else if (Uri.tryParse(event.coverUrl)?.scheme == 'https')
          ClipRRect(
            borderRadius: AppRadius.borderR16,
            child: AspectRatio(
              aspectRatio: 2,
              child: Image.network(
                event.coverUrl,
                fit: BoxFit.cover,
                semanticLabel: 'Ảnh bìa ${event.title}',
                errorBuilder: (_, _, _) => GenericEventCover(event),
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
          )
        else if (['ux-workshop', 'acoustic'].contains(event.coverKey))
          WorkshopCover(free: event.coverKey == 'acoustic')
        else
          GenericEventCover(event),
        const SizedBox(height: AppSpacing.s16),
      ],
      Wrap(
        spacing: AppSpacing.s8,
        runSpacing: AppSpacing.s8,
        children: [
          AppStatusBadge(
            label: event.isFree ? 'Tham gia tự do' : 'Cần đăng ký',
            variant: AppBadgeVariant.warning,
          ),
          if (!event.isFree)
            AppStatusBadge(
              label: event.status == 'cancelled'
                  ? 'Đã hủy'
                  : 'Còn ${event.available} chỗ',
              variant: AppBadgeVariant.success,
            ),
        ],
      ),
      const SizedBox(height: AppSpacing.s12),
      Text(event.title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: AppSpacing.s8),
      Text(event.clubName, style: const TextStyle(color: AppColors.primary)),
      const SizedBox(height: AppSpacing.s12),
      EventPanel(
        children: [
          Text(eventWhen(event)),
          Text(event.location),
          if (event.deadline != null && !event.isFree)
            Text(
              'Hạn đăng ký: ${eventTime(event.deadline!)} · ${eventDate(event.deadline!)}',
            ),
        ],
      ),
    ],
  );
}

class EventCard extends StatelessWidget {
  const EventCard(this.event, {super.key, required this.onTap});
  final Event event;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: EventSummary(event, cover: true),
      ),
    ),
  );
}

class EventFailure extends StatelessWidget {
  const EventFailure({super.key, required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => AppErrorState(
    title: 'Chưa tải được dữ liệu',
    message:
        'Kiểm tra kết nối rồi thử lại. Nếu lỗi tiếp diễn, liên hệ nhóm hỗ trợ.',
    onRetry: onRetry,
  );
}
