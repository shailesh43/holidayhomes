
import 'package:flutter/material.dart';

class ActionButtonSquare extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconBgColor;
  final Color? iconColor;
  final Color? labelColor;
  final bool enabled;

  const ActionButtonSquare({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconBgColor,
    this.iconColor,
    this.labelColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedIconBg = enabled
        ? (iconBgColor ?? const Color.fromRGBO(232, 240, 254, 1))
        : Colors.grey.shade200;
    final resolvedIconColor = enabled
        ? (iconColor ?? const Color.fromRGBO(0, 100, 200, 0.75))
        : Colors.grey.shade400;
    final resolvedLabelColor = enabled
        ? (labelColor ?? const Color.fromRGBO(5, 25, 75, 1))
        : Colors.grey.shade400;

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: resolvedIconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 32,
                color: resolvedIconColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
                color: resolvedLabelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}