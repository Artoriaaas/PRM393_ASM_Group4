import 'dart:convert';

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
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.s8),
          children[i],
        ],
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
    padding: const EdgeInsets.all(AppSpacing.s16),
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
          'packages/eventhub_core/assets/icons/event_calendar.svg',
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
        _EventCardCover(event),
        const SizedBox(height: AppSpacing.s16),
      ],
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: AppStatusBadge(
              label: event.isFree ? 'Tham gia tự do' : 'Cần đăng ký',
              variant: AppBadgeVariant.warning,
            ),
          ),
          if (!event.isFree)
            Flexible(
              child: AppStatusBadge(
                label: event.status == 'cancelled'
                    ? 'Đã hủy'
                    : 'Còn ${event.available} chỗ',
                variant: AppBadgeVariant.success,
              ),
            ),
        ],
      ),
      const SizedBox(height: 12),
      Text(event.title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text(event.clubName, style: const TextStyle(color: AppColors.primary)),
      const SizedBox(height: 16),
      EventPanel(
        children: [
          _EventFact(
            Icons.calendar_today_outlined,
            'Thời gian diễn ra',
            eventWhen(event),
          ),
          _EventFact(Icons.location_on_outlined, 'Địa điểm', event.location),
          if (event.deadline != null && !event.isFree)
            _EventFact(
              Icons.schedule,
              'Hạn đăng ký',
              '${eventTime(event.deadline!)} · ${eventDate(event.deadline!)}',
            ),
        ],
      ),
    ],
  );
}

class _EventFact extends StatelessWidget {
  const _EventFact(this.icon, this.label, this.value);
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
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
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Text(value),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Compact event identity used by forms, registrations and check-in receipts.
class EventIdentityCard extends StatelessWidget {
  const EventIdentityCard(this.event, {super.key});
  final Event event;
  @override
  Widget build(BuildContext context) => EventPanel(
    children: [
      Text(event.title, style: Theme.of(context).textTheme.titleMedium),
      Text(
        eventWhen(event),
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      Text(event.clubName, style: const TextStyle(color: AppColors.primary)),
      Text(
        event.location,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    ],
  );
}

class EventNotice extends StatelessWidget {
  const EventNotice(
    this.message, {
    super.key,
    this.variant = AppBadgeVariant.info,
  });
  final String message;
  final AppBadgeVariant variant;
  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      AppBadgeVariant.success => (
        AppColors.successContainer,
        AppColors.success,
      ),
      AppBadgeVariant.warning => (
        AppColors.warningContainer,
        AppColors.warning,
      ),
      AppBadgeVariant.error => (AppColors.errorContainer, AppColors.error),
      _ => (AppColors.infoContainer, AppColors.info),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.borderR12),
      child: Text(message, style: TextStyle(color: fg)),
    );
  }
}

class EventParticipantCard extends StatelessWidget {
  const EventParticipantCard(
    this.participant, {
    super.key,
    this.showEmail = true,
  });
  final Participant participant;
  final bool showEmail;
  @override
  Widget build(BuildContext context) => EventPanel(
    children: [
      Text(
        showEmail ? 'Thông tin đăng ký' : 'Người tham gia',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      if (showEmail)
        const Text(
          'Họ và tên',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      Text(participant.name, style: Theme.of(context).textTheme.titleMedium),
      if (showEmail) ...[
        const SizedBox(height: 8),
        const Text(
          'Email liên hệ',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        Text(participant.email),
      ],
      Text(
        participant.group == 'student'
            ? 'Sinh viên FPTU · ${participant.cohort} (tự khai)'
            : 'Khách ngoài trường (tự khai)',
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    ],
  );
}

class EventCard extends StatelessWidget {
  const EventCard(this.event, {super.key, required this.onTap});
  final Event event;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Xem sự kiện ${event.title}',
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Reuse only the cover from the detail header; list metadata stays compact.
              _EventCardCover(event),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: AppStatusBadge(
                  label: event.isFree ? 'Tham gia tự do' : 'Cần đăng ký',
                  variant: AppBadgeVariant.warning,
                ),
              ),
              const SizedBox(height: 8),
              Text(event.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                event.clubName,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              _CardLine(Icons.calendar_today_outlined, eventWhen(event)),
              const SizedBox(height: 8),
              _CardLine(Icons.location_on_outlined, event.location),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 4,
                children: [
                  if (!event.isFree)
                    Text(
                      'Còn ${event.available} chỗ',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (event.deadline != null && !event.isFree)
                    Text(
                      'Hạn ${eventTime(event.deadline!)} · ${eventDate(event.deadline!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ],
          ),
        ),
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

class _EventCardCover extends StatelessWidget {
  const _EventCardCover(this.event);
  final Event event;
  @override
  Widget build(BuildContext context) {
    return (event.coverUrl.isEmpty &&
            RegExp(r'^[a-z0-9-]+$').hasMatch(event.coverKey) &&
            [
              'ux-design',
              'acoustic-live',
              'badminton',
              'green-campus',
              'career-connect',
            ].contains(event.coverKey))
        ? ClipRRect(
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
        : event.coverUrl.startsWith('data:image')
        ? ClipRRect(
            borderRadius: AppRadius.borderR16,
            child: AspectRatio(
              aspectRatio: 2,
              child: Builder(
                builder: (context) {
                  try {
                    final base64Str = event.coverUrl.substring(
                      event.coverUrl.indexOf(',') + 1,
                    );
                    final bytes = base64Decode(base64Str);
                    return Image.memory(
                      bytes,
                      fit: BoxFit.cover,
                      semanticLabel: 'Ảnh bìa ${event.title}',
                      errorBuilder: (_, _, _) => GenericEventCover(event),
                    );
                  } catch (_) {
                    return GenericEventCover(event);
                  }
                },
              ),
            ),
          )
        : Uri.tryParse(event.coverUrl)?.scheme == 'https'
        ? ClipRRect(
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
        : ['ux-workshop', 'acoustic'].contains(event.coverKey)
        ? WorkshopCover(free: event.coverKey == 'acoustic')
        : GenericEventCover(event);
  }
}

class _CardLine extends StatelessWidget {
  const _CardLine(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 18, color: AppColors.primary),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
    ],
  );
}
