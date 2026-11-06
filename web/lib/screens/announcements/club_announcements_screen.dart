import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../../viewmodels/announcements_viewmodel.dart';

class ClubAnnouncementsScreen extends ConsumerStatefulWidget {
  const ClubAnnouncementsScreen({super.key});

  @override
  ConsumerState<ClubAnnouncementsScreen> createState() =>
      _ClubAnnouncementsScreenState();
}

class _ClubAnnouncementsScreenState
    extends ConsumerState<ClubAnnouncementsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  String _scope = 'club'; // 'club' | 'event'
  String? _selectedEventId;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final res = await ref.read(announcementsViewModelProvider.notifier).publish(
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          scope: _scope,
          eventId: _scope == 'event' ? _selectedEventId : null,
        );

    if (res.isSuccess) {
      _titleController.clear();
      _bodyController.clear();
      setState(() {
        _scope = 'club';
        _selectedEventId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(announcementsViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSubtle,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phát hành Thông báo CLB',
                  style: AppTypography.textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  'Gửi tin nhắn thông báo hiển thị thời gian thực trong Inbox ứng dụng Mobile của sinh viên',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s20),

            if (state.successMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.s12),
                decoration: BoxDecoration(
                  color: AppColors.successContainer,
                  borderRadius: AppRadius.borderR8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Text(
                        state.successMessage!,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSuccessContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
            ],

            if (state.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.s12),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: AppRadius.borderR8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 20),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
            ],

            // 2-Column Responsive Layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 950;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column 1: Compose Form
                      Expanded(
                        flex: 5,
                        child: _buildComposeCard(state),
                      ),
                      const SizedBox(width: AppSpacing.s24),
                      // Column 2: History List
                      Expanded(
                        flex: 6,
                        child: _buildHistoryCard(state),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildComposeCard(state),
                      const SizedBox(height: AppSpacing.s24),
                      _buildHistoryCard(state),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposeCard(AnnouncementsState state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderR16,
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soạn thông báo mới',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),

            // Scope selection
            Text(
              'Phạm vi thông báo (*)',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Wrap(
              spacing: AppSpacing.s12,
              runSpacing: AppSpacing.s8,
              children: [
                ChoiceChip(
                  label: const Text('Toàn bộ người quan tâm CLB'),
                  selected: _scope == 'club',
                  onSelected: (sel) {
                    if (sel) {
                      setState(() {
                        _scope = 'club';
                        _selectedEventId = null;
                      });
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Gắn với 1 sự kiện cụ thể'),
                  selected: _scope == 'event',
                  onSelected: (sel) {
                    if (sel) {
                      setState(() {
                        _scope = 'event';
                        if (state.events.isNotEmpty) {
                          _selectedEventId = state.events.first.id;
                        }
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),

            // Event selector dropdown if scope == event
            if (_scope == 'event') ...[
              Text(
                'Chọn sự kiện liên quan (*)',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              DropdownButtonFormField<String>(
                initialValue: _selectedEventId ??
                    (state.events.isNotEmpty ? state.events.first.id : null),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceSubtle,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12,
                    vertical: AppSpacing.s12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.borderR8,
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                items: state.events
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.id,
                        child: Text(
                          e.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() => _selectedEventId = val);
                },
                validator: (val) {
                  if (_scope == 'event' && (val == null || val.isEmpty)) {
                    return 'Vui lòng chọn sự kiện liên quan.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s16),
            ],

            // Title
            Text(
              'Tiêu đề thông báo (*)',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            TextFormField(
              key: const Key('announcement_title_field'),
              controller: _titleController,
              maxLength: 120,
              validator: (v) {
                final trimmed = v?.trim() ?? '';
                if (trimmed.isEmpty) return 'Vui lòng nhập tiêu đề.';
                if (trimmed.length > 120) return 'Tiêu đề tối đa 120 ký tự.';
                return null;
              },
              decoration: InputDecoration(
                hintText: 'VD: Thông báo thay đổi phòng tổ chức workshop...',
                filled: true,
                fillColor: AppColors.surfaceSubtle,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.borderR8,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),

            // Body
            Text(
              'Nội dung chi tiết (*)',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            TextFormField(
              key: const Key('announcement_body_field'),
              controller: _bodyController,
              maxLines: 5,
              maxLength: 1000,
              validator: (v) {
                final trimmed = v?.trim() ?? '';
                if (trimmed.isEmpty) return 'Vui lòng nhập nội dung.';
                if (trimmed.length > 1000) return 'Nội dung tối đa 1000 ký tự.';
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Nhập nội dung thông báo gửi tới người tham gia...',
                filled: true,
                fillColor: AppColors.surfaceSubtle,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.borderR8,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s20),

            // Submit Button
            AppButton(
              label: 'Phát hành thông báo',
              icon: const Icon(Icons.send_rounded, size: 18),
              isLoading: state.isPublishing,
              onPressed: state.isPublishing ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(AnnouncementsState state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderR16,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lịch sử thông báo đã gửi',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              AppStatusBadge(
                label: '${state.announcements.length} tin',
                variant: AppBadgeVariant.neutral,
              ),
            ],
          ),
          const Divider(height: AppSpacing.s24, color: AppColors.border),

          state.loadState.when(
            initial: () => const Center(child: AppLoadingState()),
            loading: (_) => const Center(child: AppLoadingState()),
            empty: (msg) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s40),
              child: Center(
                child: Text(
                  msg ?? 'Chưa có thông báo nào được phát hành.',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            error: (failure, _) => Center(
              child: AppErrorState(
                title: 'Lỗi tải lịch sử',
                message: failure.message,
              ),
            ),
            data: (announcements, updatedAt, isStale) {
              if (announcements.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s40),
                  child: Center(
                    child: Text(
                      'Chưa có thông báo nào được phát hành.',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: announcements.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: AppSpacing.s20, color: AppColors.border),
                itemBuilder: (context, index) {
                  final ann = announcements[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              ann.title,
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          AppStatusBadge(
                            label: ann.scope == 'event'
                                ? 'Sự kiện'
                                : 'Toàn CLB',
                            variant: ann.scope == 'event'
                                ? AppBadgeVariant.info
                                : AppBadgeVariant.neutral,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        ann.body,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        ann.createdAt != null
                            ? '${ann.createdAt!.day}/${ann.createdAt!.month}/${ann.createdAt!.year} lúc ${ann.createdAt!.hour}:${ann.createdAt!.minute.toString().padLeft(2, '0')}'
                            : 'Vừa xong',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
