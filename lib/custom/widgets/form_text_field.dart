import 'package:flutter/material.dart';

/// A custom form text field with label and optional required indicator.

/// This widget displays a labeled text field with consistent styling
/// and an optional red asterisk for required fields.

class FormTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool required;
  final TextEditingController? controller;
  final int maxLines;

  /// New: Optional errorText to trigger error border
  final String? errorText;

  const FormTextField({
    super.key,
    required this.label,
    this.hint = 'Enter Value',
    this.required = false,
    this.controller,
    this.maxLines = 1,
    this.errorText, // <-- new
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF757575),
                ),
              ),
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF757575),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: errorText != null ? Color.fromRGBO(250, 98, 98, 1.0) : Color(0xFFE0E0E0)),
            ),
            errorText: errorText, // <-- shows red border automatically
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: errorText != null ? Color.fromRGBO(250, 98, 98, 1.0) : Color(0xFF848484)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
