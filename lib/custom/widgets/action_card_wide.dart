import 'package:flutter/material.dart';

class ActionCardWide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconBgColor;
  final Color? iconColor;
  final bool enabled;

  const ActionCardWide({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconBgColor,
    this.iconColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedIconBg =
    enabled ? (iconBgColor ?? Colors.grey.shade200) : Colors.grey.shade100;
    final resolvedIconColor =
    enabled ? (iconColor ?? Colors.grey.shade600) : Colors.grey.shade400;

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: resolvedIconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 28,
                color: resolvedIconColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: enabled ? onTap : null,
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: enabled
                            ? const Color.fromRGBO(0, 0, 0, 0.80)
                            : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: enabled ? Colors.grey[500] : Colors.grey[350],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}