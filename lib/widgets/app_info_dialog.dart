import 'package:flutter/material.dart';

import 'app_button.dart';
import '../theme/theme.dart';

class AppInfoDialog extends StatelessWidget {
  const AppInfoDialog({super.key, required this.title, required this.message});
  final String title, message;
  @override
  Widget build(BuildContext context) => Dialog(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s16),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.s16),
            AppButton(
              label: 'Đóng',
              variant: AppButtonVariant.text,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    ),
  );
}
