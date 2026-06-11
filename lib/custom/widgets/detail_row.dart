import 'package:flutter/material.dart';

/// A custom row widget that displays a label-value pair.
/// Label on the left, value on the right.

class DetailRow extends StatelessWidget {
  /// Required
  final String label;
  final String value;

  /// Optional
  final bool isMultiline;
  final bool isBold;
  final TextAlign valueAlign;
  final EdgeInsetsGeometry padding;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isMultiline = false,
    this.isBold = false,
    this.valueAlign = TextAlign.right,
    this.padding = const EdgeInsets.only(bottom: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment:
        isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF757575),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: valueAlign,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
