
import 'package:flutter/material.dart';

class SnackBarService {
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static void showSnackBar(String message, {bool isError = false}) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }
}
