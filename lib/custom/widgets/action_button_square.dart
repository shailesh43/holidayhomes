import 'package:flutter/material.dart';

class ActionButtonSquare extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconBgColor;
  final Color? iconColor;
  final Color? labelColor;

  const ActionButtonSquare({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconBgColor,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconBgColor ?? const Color.fromRGBO(232, 240, 254, 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 32,
              color: iconColor ?? const Color.fromRGBO(0, 100, 200, 0.75),
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
              color: labelColor ?? const Color.fromRGBO(5, 25, 75, 1),
            ),
          ),
        ],
      ),
    );
  }
}