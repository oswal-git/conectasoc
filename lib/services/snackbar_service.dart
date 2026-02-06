import 'package:flutter/material.dart';

class SnackBarService {
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static void showSnackBar(
    String message, {
    bool isError = false,
    Duration? duration,
  }) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }
}
