import 'package:flutter/material.dart';

import 'package:flutter_app/generated/l10n.dart';

/// 统一的错误重试视图。
///
/// 在所有 BLoC 页面的 [BlocBuilder] error 分支中使用，
/// 替代重复的 `_buildError` 方法。
class ErrorRetryView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorRetryView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(
            message.isNotEmpty ? message : loc.loadFailed,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(loc.retry),
          ),
        ],
      ),
    );
  }
}
