import 'package:flutter/material.dart';
import '../../network/api_models/booking.dart';

class BaseModal extends StatelessWidget {
  final Booking request;
  final String title;
  final Widget content;
  final Widget? bottom;

  const BaseModal({
    super.key,
    required this.request,
    required this.title,
    required this.content,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color.fromRGBO(220, 220, 220, 1.0)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          /// BODY (SCROLLABLE)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: content,
            ),
          ),

          /// FIXED BOTTOM ACTIONS
          if (bottom != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color.fromRGBO(220, 220, 220, 1.0)),
                ),
              ),
              child: bottom,
            ),
        ],
      ),
    );
  }
}
