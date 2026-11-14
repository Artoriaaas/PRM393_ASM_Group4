import '../../viewmodels/cloud_tools_viewmodel.dart';
import '../../theme/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/event_data_providers.dart';
import '../../viewmodels/event_viewmodels.dart';
import '../../widgets/widgets.dart';
import '../../widgets/event_widgets.dart';

class EventListScreen extends ConsumerStatefulWidget {
  const EventListScreen({
    super.key,
    this.search = false,
    this.initialQuery = '',
  });
  final bool search;
  final String initialQuery;
  @override
  ConsumerState<EventListScreen> createState() => _EventListState();
}

class _EventListState extends ConsumerState<EventListScreen> {
  late final TextEditingController query = TextEditingController(
    text: widget.initialQuery,
  );
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(eventFilterProvider.notifier).set(query: widget.initialQuery);
      }
    });
  }

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(eventFilterProvider, (_, next) {
      if (query.text != next.query) {
        query.value = TextEditingValue(
          text: next.query,
          selection: TextSelection.collapsed(offset: next.query.length),
        );
      }
    });
    final events = ref.watch(eventsProvider);
    final filter = ref.watch(eventFilterProvider);
    final filterVM = ref.read(eventFilterProvider.notifier);
    return Scaffold(
      backgroundColor: widget.search
          ? AppColors.surface
          : AppColors.surfaceSubtle,
      appBar: AppTopBar(
        title: (!widget.search
            ? 'Khám phá'
            : filter.query.trim().isEmpty
            ? 'Tất cả sự kiện'
            : 'Kết quả tìm kiếm'),
        showBackButton: widget.search,
      ),
      body: events.when(
        loading: () => const AppLoadingState(),
        error: (_, _) =>
            EventFailure(onRetry: () => ref.invalidate(eventsProvider)),
        data: (all) {
          final filtered =
              ref
                  .watch(
                    widget.search
                        ? eventFeedProvider
                        : recommendationFeedProvider,
                  )
                  .asData
                  ?.value ??
              [];
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(eventsProvider);
              await ref.read(eventsProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.s16),
              children: [
                if (!widget.search) ...[
                  Text(
                    'Sắp tới tại TP.HCM',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Text('Tìm một hoạt động phù hợp với bạn'),
                  const SizedBox(height: AppSpacing.s16),
                ],
                AppSearchField(
                  controller: query,
                  hintText: 'Tìm sự kiện, CLB...',
                  onChanged: (q) {
                    if (widget.search) filterVM.set(query: q);
                  },
                  onSubmitted: (q) {
                    filterVM.set(query: q);
                    filterVM.searchSubmitted(q);
                    if (!widget.search) {
                      context.push(
                        Uri(
                          path: '/discover/search',
                          queryParameters: {'q': q},
                        ).toString(),
                      );
                    }
                  },
                ),
                if (widget.search) ...[
                  const SizedBox(height: AppSpacing.s12),
                  AppButton(
                    label: 'Lọc sự kiện',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const _EventFilterSheet(),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.s16),
                if (!widget.search)
                  Text(
                    'Dành cho bạn',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                if (widget.search)
                  Text(
                    '${filtered.length} sự kiện',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                if (!widget.search &&
                    !ref.watch(cloudToolsProvider).settings.showRecommendations)
                  const Text(
                    'Gợi ý sự kiện đang tạm ẩn. Dùng thanh tìm kiếm để tìm sự kiện.',
                  )
                else if (filtered.isEmpty)
                  AppEmptyState(
                    title: all.isEmpty
                        ? 'Chưa có sự kiện'
                        : 'Chưa tìm thấy sự kiện',
                    message: all.isEmpty
                        ? 'Sự kiện mới sẽ xuất hiện tại đây. Kéo xuống để cập nhật.'
                        : 'Thử từ khóa khác hoặc đổi bộ lọc.',
                  ),
                for (final e in filtered)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.s16),
                    child: EventCard(
                      e,
                      onTap: () => context.push('/events/${e.id}'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EventFilterSheet extends ConsumerWidget {
  const _EventFilterSheet();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(eventFilterProvider);
    final vm = ref.read(eventFilterProvider.notifier);
    final topics = ref.watch(eventTopicsProvider);
    final clubs = ref.watch(eventClubsProvider);
    final count = ref.watch(eventFeedProvider).asData?.value.length;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.s16,
          right: AppSpacing.s16,
          top: AppSpacing.s16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.s16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Lọc sự kiện',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Đóng bộ lọc',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Wrap(
                spacing: AppSpacing.s8,
                children: [
                  FilterChip(
                    label: const Text('Hôm nay'),
                    selected: filter.today,
                    onSelected: (value) => vm.set(today: value),
                  ),
                  for (final topic in topics)
                    FilterChip(
                      label: Text(topic),
                      selected: filter.topic == topic,
                      onSelected: (value) =>
                          vm.set(topic: topic, clearTopic: !value),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),
              DropdownButtonFormField<String>(
                key: ValueKey(filter.club),
                initialValue: filter.club,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Câu lạc bộ'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Tất cả CLB'),
                  ),
                  for (final club in clubs)
                    DropdownMenuItem(value: club, child: Text(club)),
                ],
                onChanged: (value) =>
                    vm.set(club: value, clearClub: value == null),
              ),
              const SizedBox(height: AppSpacing.s16),
              AppButton(
                label: count == null ? 'Xem kết quả' : 'Xem $count sự kiện',
                onPressed: () => Navigator.pop(context),
              ),
              AppButton(
                variant: AppButtonVariant.text,
                onPressed: vm.reset,
                label: 'Xóa lọc',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
