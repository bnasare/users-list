import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  scaffoldMessenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      content: SizedBox(
        height: 20,
        child: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(16),
    ),
  );
}
