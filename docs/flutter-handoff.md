# Flutter handoff — ánh xạ triển khai mobile Lab 3

Nguồn đã mở: handoff/flutter-handoff.md trong repo Lab2 prm323-lab2-group2, revision 31cd447, ngày 07/11/2026. Bản nguồn tự ghi là đặc tả trước khi dựng Figma, nên không dùng nó để khẳng định Final UI giống pixel 1:1. File này ghi tên triển khai thực tế để người chấm không cần đường dẫn máy cá nhân.

## Token → Flutter

| Token / mục đích Lab2 | Giá trị | Code hiện tại |
|---|---|---|
| Action/Primary | #C74316 | AppColors.primary → ColorScheme.primary |
| Text/Primary | #2B3445 | AppColors.textPrimary → ColorScheme.onSurface |
| Text/Secondary và Placeholder | #5F6B7A | AppColors.textSecondary; InputDecorationTheme.hintStyle và AppSearchField |
| Border/Input | #CBD2DC | AppColors.borderSubtle → ColorScheme.outline; input borders |
| Border/Default | #E3E7ED | AppColors.border → ColorScheme.outlineVariant |
| Surface/Default và Text/OnAction | #FFFFFF | AppColors.surface/onPrimary → ColorScheme.surface/onPrimary |
| Surface/Subtle | #F8F9FB | AppColors.surfaceSubtle → scaffoldBackgroundColor |
| Success / Warning / Error / Info | Nhóm palette trong app_colors.dart | EventHubSemanticColors ThemeExtension và status widgets |
| Typography | Be Vietnam Pro; 32/28/24/20/18/16/14 | AppTypography.textTheme → ThemeData.textTheme |
| Body/S | Handoff ghi 12 cho nhãn phụ | Body thực trong code tối thiểu14; caption riêng labelSmall12, không dùng bodySmall12 |
| Space | 0/4/8/12/16/20/24/32/40/48 | AppSpacing.s*; spacing phụ cho artwork/badge được đặt tên |
| Radius | 6/8/12/16/24/999 | AppRadius.r* và borderR* |
| Shadow | 0; 0/2/8/0 6%; 0/8/24/0 10% | AppShadows.elevation0/1/2 |
| Touch minimum | ≥48dp theo Lab3 | AppTouchTargets.min/minConstraints; button/icon/chip/navigation |

## Component → widget

| Component | Widget thực tế / variants |
|---|---|
| Button | AppButton(primary/secondary/text, isLoading/isDisabled/icon) |
| Text field | AppTextField, AppSearchField; error/disabled/password states |
| Card / event | EventCard, EventPanel, EventSummary; cover theo dữ liệu event |
| Navigation | AppNavigationBar; MainShellScreen dùng StatefulShellRoute |
| App bar | AppTopBar; showBackButton/onBack/actions/subtitle |
| Confirmation / information dialog | AppConfirmationDialog; AppInfoDialog |
| Selection chip | AppChoiceChip(selected/onSelected), touch48 |
| Loading / empty / error | AppLoadingState / AppEmptyState / AppErrorState (EventFailure wrapper) |
| Camera preview | QrCameraPreview chỉ render platform surface; ScannerViewModel điều khiển qua QrCamera contract |

Các khác biệt layout/ảnh hiện hành ghi trong design-traceability.md. Không tự sửa file Figma theo yêu cầu chủ repo; yêu cầu cập nhật Figma của đề vẫn cần hoàn thiện hoặc được giảng viên chấp thuận.
