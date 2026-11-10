import 'package:flutter/material.dart';

class OfflineView extends StatelessWidget {
  const OfflineView({
    super.key,
    required this.isChecking,
    required this.onRetry,
  });

  final bool isChecking;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ColoredBox(
      color: colors.surface,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _OfflineIcon(colors: colors),
              const SizedBox(height: 32),
              Text(
                'You’re offline',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                'Please check your internet connection and try again. '
                'We’ll reconnect as soon as you’re back online.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              _RetryButton(
                theme: theme,
                isChecking: isChecking,
                onRetry: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineIcon extends StatelessWidget {
  const _OfflineIcon({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.wifi_off_rounded,
        size: 56,
        color: colors.onPrimaryContainer,
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({
    required this.theme,
    required this.isChecking,
    required this.onRetry,
  });

  final ThemeData theme;
  final bool isChecking;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isChecking ? null : onRetry,
      icon: isChecking
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh_rounded),
      label: Text(isChecking ? 'Checking…' : 'Try again'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: theme.textTheme.labelLarge
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}