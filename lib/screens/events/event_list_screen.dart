import '../../viewmodels/cloud_tools_viewmodel.dart';
import '../../theme/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/event_providers.dart';
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
      appBar: AppBar(
        title: Text(widget.search ? 'Kết quả tìm kiếm' : 'Khám phá'),
        centerTitle: false,
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
                  onChanged: (q) => filterVM.set(query: q),
                  onSubmitted: (q) {
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
                const SizedBox(height: AppSpacing.s12),
                Wrap(
                  spacing: AppSpacing.s8,
                  runSpacing: AppSpacing.s8,
                  children: [
                    FilterChip(
                      label: const Text('Hôm nay'),
                      selected: filter.today,
                      onSelected: (v) => filterVM.set(today: v),
                    ),
                    for (final t
                        in all
                            .map((e) => e.topic)
                            .where((t) => t.isNotEmpty)
                            .toSet())
                      FilterChip(
                        label: Text(t),
                        selected: filter.topic == t,
                        onSelected: (v) =>
                            filterVM.set(topic: t, clearTopic: !v),
                      ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  initialValue: filter.club,
                  key: ValueKey(filter.club),
                  decoration: const InputDecoration(labelText: 'Câu lạc bộ'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Tất cả CLB'),
                    ),
                    for (final c in all.map((e) => e.clubName).toSet())
                      DropdownMenuItem(value: c, child: Text(c)),
                  ],
                  onChanged: (v) => filterVM.set(club: v, clearClub: v == null),
                  isExpanded: true,
                ),
                TextButton(
                  onPressed: () {
                    query.clear();
                    filterVM.reset();
                  },
                  child: const Text('Xóa từ khóa và bộ lọc'),
                ),
                if (!widget.search)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Dành cho bạn',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/discover/search'),
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                Text(
                  '${filtered.length} sự kiện',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (!widget.search &&
                    !ref.watch(cloudToolsProvider).settings.showRecommendations)
                  const Text(
                    'Gợi ý sự kiện đang tạm ẩn. Dùng tìm kiếm hoặc Xem tất cả để xem danh sách.',
                  )
                else if (filtered.isEmpty)
                  const AppEmptyState(
                    title: 'Chưa tìm thấy sự kiện',
                    message: 'Thử từ khóa khác hoặc đổi bộ lọc.',
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
