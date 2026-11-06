import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_confirmation_dialog.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error_state.dart';
import '../../widgets/app_icon_button.dart';
import '../../widgets/app_loading_state.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/app_status_badge.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_top_bar.dart';

enum PreviewViewportWidth {
  full(null, 'Toàn màn hình'),
  w360(360.0, '360 dp (Compact)'),
  w412(412.0, '412 dp (Standard)');

  const PreviewViewportWidth(this.width, this.label);
  final double? width;
  final String label;
}

/// Development-only Component Preview Screen for verifying UI components
/// at 360 dp and 412 dp screen widths with various states, long text, and semantics.
class ComponentPreviewScreen extends StatefulWidget {
  const ComponentPreviewScreen({super.key});

  @override
  State<ComponentPreviewScreen> createState() => _ComponentPreviewScreenState();
}

class _ComponentPreviewScreenState extends State<ComponentPreviewScreen> {
  PreviewViewportWidth _selectedViewport = PreviewViewportWidth.full;
  bool _dialogPending = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF1F7),
      appBar: AppTopBar(
        title: 'Xem thử Component (Development)',
        subtitle: 'Kiểm tra token, state, touch target và responsive',
        showBackButton: context.canPop(),
        onBack: () => context.pop(),
        actions: [
          PopupMenuButton<PreviewViewportWidth>(
            icon: const Icon(Icons.devices, color: AppColors.textPrimary),
            tooltip: 'Chọn kích thước khung nhìn',
            initialValue: _selectedViewport,
            onSelected: (width) => setState(() => _selectedViewport = width),
            itemBuilder: (context) => [
              for (final vp in PreviewViewportWidth.values)
                PopupMenuItem(
                  value: vp,
                  child: Text(
                    vp.label,
                    style: TextStyle(
                      fontWeight: _selectedViewport == vp
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _selectedViewport == vp
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: _selectedViewport.width ?? double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            boxShadow: _selectedViewport.width != null
                ? const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
            border: _selectedViewport.width != null
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Column(
            children: [
              _buildViewportBanner(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.screenMargin),
                  children: [
                    _buildSectionTitle('1. Hướng dẫn & Đo lường'),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Yêu cầu kiểm tra:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          const Text(
                            '• Khung nhìn: chuyển đổi 360 dp và 412 dp phía trên.',
                          ),
                          const Text(
                            '• Touch target: mọi nút / trường / icon tương tác ≥ 48 dp.',
                          ),
                          const Text(
                            '• Typography: Body text ≥ 14 sp theo rubric.',
                          ),
                          const Text(
                            '• Text dài: xử lý co giãn, ellipsis hoặc xuống hàng an toàn.',
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          Wrap(
                            spacing: AppSpacing.s8,
                            children: [
                              for (final vp in PreviewViewportWidth.values)
                                ChoiceChip(
                                  label: Text(vp.label),
                                  selected: _selectedViewport == vp,
                                  onSelected: (_) =>
                                      setState(() => _selectedViewport = vp),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    _buildSectionTitle('2. Nút bấm (AppButton)'),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppButton(
                            label: 'Nút Primary (Bình thường)',
                            onPressed: () {},
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          AppButton(
                            label: 'Nút Primary (Đang tải / Loading)',
                            isLoading: true,
                            onPressed: () {},
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          AppButton(
                            label: 'Nút Primary (Vô hiệu hóa / Disabled)',
                            isDisabled: true,
                            onPressed: () {},
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          AppButton(
                            label: 'Nút có Icon phía trước',
                            icon: const Icon(Icons.calendar_month, size: 20),
                            onPressed: () {},
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          AppButton(
                            label: 'Nút Secondary (Outlined)',
                            variant: AppButtonVariant.secondary,
                            onPressed: () {},
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          AppButton(
                            label: 'Nút Text (Không viền)',
                            variant: AppButtonVariant.text,
                            onPressed: () {},
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          AppButton(
                            label: 'Nút có nhãn cực dài để kiểm tra tràn văn bản trên màn hình nhỏ 360dp không bị lỗi pixel overflow',
                            variant: AppButtonVariant.primary,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    _buildSectionTitle('3. Nút Icon (AppIconButton — 48x48dp)'),
                    _buildCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          AppIconButton(
                            icon: const Icon(Icons.favorite_border),
                            tooltip: 'Yêu thích',
                            onPressed: () {},
                          ),
                          AppIconButton(
                            icon: const Icon(Icons.share),
                            tooltip: 'Chia sẻ',
                            onPressed: () {},
                          ),
                          const AppIconButton(
                            icon: Icon(Icons.refresh),
                            tooltip: 'Đang tải',
                            isLoading: true,
                            onPressed: null,
                          ),
                          const AppIconButton(
                            icon: Icon(Icons.delete_outline),
                            tooltip: 'Đã vô hiệu hóa',
                            isEnabled: false,
                            onPressed: null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    _buildSectionTitle('4. Trường nhập (AppTextField)'),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const AppTextField(
                            labelText: 'Họ và tên',
                            hintText: 'Nhập họ và tên sinh viên',
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          const AppTextField(
                            labelText: 'Mật khẩu (có nút ẩn/hiện)',
                            hintText: 'Nhập mật khẩu',
                            obscureText: true,
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          const AppTextField(
                            labelText: 'Trường có lỗi dữ liệu',
                            initialValue: 'khong_hop_le@',
                            errorText: 'Email không đúng định dạng',
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          const AppTextField(
                            labelText: 'Trường vô hiệu hóa (Disabled)',
                            initialValue: 'SE123456 (Khóa K18 FPTU)',
                            enabled: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    _buildSectionTitle('5. Tìm kiếm (AppSearchField)'),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppSearchField(
                            onChanged: (val) =>
                                setState(() => _searchQuery = val),
                          ),
                          if (_searchQuery.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.s8),
                            Text(
                              'Đang tìm: "$_searchQuery"',
                              style: AppTypography.textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    _buildSectionTitle(
                      '6. Huy hiệu trạng thái (AppStatusBadge)',
                    ),
                    _buildCard(
                      child: const Wrap(
                        spacing: AppSpacing.s8,
                        runSpacing: AppSpacing.s8,
                        children: [
                          AppStatusBadge(
                            label: 'ĐÃ CHECK-IN',
                            variant: AppBadgeVariant.success,
                            icon: Icon(Icons.check_circle_outline),
                          ),
                          AppStatusBadge(
                            label: 'CHỜ XÁC NHẬN',
                            variant: AppBadgeVariant.warning,
                            icon: Icon(Icons.schedule),
                          ),
                          AppStatusBadge(
                            label: 'ĐÃ HỦY ĐĂNG KÝ',
                            variant: AppBadgeVariant.error,
                            icon: Icon(Icons.cancel_outlined),
                          ),
                          AppStatusBadge(
                            label: 'THAM GIA TỰ DO',
                            variant: AppBadgeVariant.info,
                            icon: Icon(Icons.info_outline),
                          ),
                          AppStatusBadge(
                            label: 'BẢN NHÁP',
                            variant: AppBadgeVariant.neutral,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    _buildSectionTitle(
                      '7. Hộp thoại xác nhận (AppConfirmationDialog)',
                    ),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppButton(
                            label: 'Mở Dialog xác nhận hủy đăng ký',
                            variant: AppButtonVariant.secondary,
                            onPressed: () =>
                                _showTestDialog(isDestructive: true),
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          AppButton(
                            label: 'Mở Dialog bình thường (Thông tin)',
                            variant: AppButtonVariant.secondary,
                            onPressed: () =>
                                _showTestDialog(isDestructive: false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    _buildSectionTitle(
                      '8. Trạng thái Loading (AppLoadingState)',
                    ),
                    _buildCard(
                      child: const AppLoadingState(
                        message: 'Đang đồng bộ dữ liệu sự kiện từ hệ thống...',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    _buildSectionTitle('9. Trạng thái Trống (AppEmptyState)'),
                    _buildCard(
                      child: AppEmptyState(
                        title: 'Chưa có sự kiện nào trong lịch',
                        message: 'Khám phá các sự kiện thú vị từ câu lạc bộ và nhấn Đăng ký tham gia ngay!',
                        actionLabel: 'Khám phá sự kiện',
                        onAction: () {},
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    _buildSectionTitle('10. Trạng thái Lỗi (AppErrorState)'),
                    _buildCard(
                      child: AppErrorState(
                        title: 'Không thể kết nối máy chủ',
                        message: 'Vui lòng kiểm tra lại kết nối mạng Internet của thiết bị và thử lại.',
                        onRetry: () {},
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    _buildSectionTitle('11. Bảng màu & Typography Token'),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildColorRow(
                            'Primary (#C74316)',
                            AppColors.primary,
                          ),
                          _buildColorRow(
                            'Text Primary (#2B3445)',
                            AppColors.textPrimary,
                          ),
                          _buildColorRow(
                            'Text Secondary (#5F6B7A)',
                            AppColors.textSecondary,
                          ),
                          _buildColorRow(
                            'Success (#147A55)',
                            AppColors.success,
                          ),
                          _buildColorRow(
                            'Warning (#9A5B00)',
                            AppColors.warning,
                          ),
                          _buildColorRow('Error (#B4233F)', AppColors.error),
                          _buildColorRow('Info (#315F9A)', AppColors.info),
                          const Divider(height: AppSpacing.s24),
                          Text(
                            'Display Small 32/40 Bold',
                            style: AppTypography.textTheme.displaySmall,
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          Text(
                            'Headline Medium 28/36 Bold',
                            style: AppTypography.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          Text(
                            'Title Large 20/28 SemiBold',
                            style: AppTypography.textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          Text(
                            'Title Medium 18/26 SemiBold',
                            style: AppTypography.textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          Text(
                            'Body Large 16/24 Regular',
                            style: AppTypography.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          Text(
                            'Body Medium 14/21 Regular (Chuẩn ≥14sp)',
                            style: AppTypography.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          Text(
                            'Label Small 12/16 Regular (Nhãn phụ)',
                            style: AppTypography.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewportBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s8,
      ),
      color: AppColors.primary,
      child: Row(
        children: [
          const Icon(Icons.aspect_ratio, color: Colors.white, size: 18),
          const SizedBox(width: AppSpacing.s8),
          Text(
            'Khung nhìn hiện tại: ${_selectedViewport.label}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (_selectedViewport.width != null)
            Text(
              '${_selectedViewport.width!.toInt()} dp',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Text(
        title,
        style: AppTypography.textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      color: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.borderR12,
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: child,
      ),
    );
  }

  Widget _buildColorRow(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Text(
            name,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showTestDialog({required bool isDestructive}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AppConfirmationDialog(
              title: isDestructive
                  ? 'Xác nhận hủy đăng ký sự kiện'
                  : 'Xác nhận đăng ký tham gia',
              message: isDestructive
                  ? 'Bạn có chắc chắn muốn hủy đăng ký? Suất tham gia của bạn sẽ được giải phóng cho sinh viên khác.'
                  : 'Vui lòng xác nhận thông tin đăng ký tham gia sự kiện.',
              confirmLabel: isDestructive ? 'Hủy đăng ký' : 'Xác nhận',
              isDestructive: isDestructive,
              isPending: _dialogPending,
              onConfirm: () async {
                setDialogState(() => _dialogPending = true);
                await Future<void>.delayed(const Duration(seconds: 1));
                if (!mounted) return;
                setDialogState(() => _dialogPending = false);
                if (dialogCtx.mounted) {
                  Navigator.of(dialogCtx).pop();
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thao tác dialog thành công')),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
