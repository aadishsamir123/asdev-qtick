import 'package:flutter/material.dart';

/// A widget that displays the qtick logo using Material 3 filled check icon
class QTickLogo extends StatelessWidget {
  final double? size;
  final Color? color;
  final bool showBrandName;

  const QTickLogo({
    super.key,
    this.size,
    this.color,
    this.showBrandName = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = size ?? 48.0;
    final iconColor = color ?? const Color(0xFFE91E63);

    if (showBrandName) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(
              Icons.check_rounded,
              size: iconSize * 0.7,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 12.0),
          Text(
            'QTick',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ],
      );
    }

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: iconColor,
        borderRadius: BorderRadius.circular(iconSize * 0.25),
      ),
      child: Icon(
        Icons.check_rounded,
        size: iconSize * 0.6,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }
}

/// A simple qtick icon without container background
class QTickIcon extends StatelessWidget {
  final double? size;
  final Color? color;

  const QTickIcon({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.check_rounded,
      size: size ?? 24.0,
      color: color ?? const Color(0xFFE91E63),
    );
  }
}
