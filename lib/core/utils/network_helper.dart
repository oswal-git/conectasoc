// lib/core/utils/network_helper.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Helper para verificar conectividad de manera cross-platform
class NetworkHelper {
  /// Verifica si hay conexión a internet
  /// En web, siempre retorna true porque el navegador ya maneja esto
  /// En móvil/desktop, podrías usar connectivity_plus
  static Future<bool> hasConnection() async {
    if (kIsWeb) {
      // En web, si el navegador está abierto, asumimos que hay conexión
      // Firebase manejará los errores de red automáticamente
      return true;
    }

    // Para móvil/desktop, podrías usar connectivity_plus aquí
    // Por ahora, retornamos true y dejamos que Firebase maneje los errores
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());

// Use conditions which work for your requirements.
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      // Mobile network available.
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      // Wi-fi is available.
      // Note for Android:
      // When both mobile and Wi-Fi are turned on system will return Wi-Fi only as active network type
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      // Ethernet connection available.
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
      // Vpn connection active.
      // Note for iOS and macOS:
      // There is no separate network interface type for [vpn].
      // It returns [other] on any device (also simulator)
    } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
      // Bluetooth connection available.
    } else if (connectivityResult.contains(ConnectivityResult.other)) {
      // Connected to a network which is not in the above mentioned networks.
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }

    return true;
  }

  /// Determina si un error es de red
  static bool isNetworkError(String errorMessage) {
    final networkKeywords = [
      'network',
      'connection',
      'internet',
      'offline',
      'timeout',
      'unreachable',
    ];

    final lowerMessage = errorMessage.toLowerCase();
    return networkKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  /// Convierte errores de red en mensajes amigables
  static String getNetworkErrorMessage(String originalError) {
    if (isNetworkError(originalError)) {
      return 'No hay conexión a internet. Por favor, verifica tu conexión y vuelve a intentarlo.';
    }
    return originalError;
  }
}
