import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Función global para estandarizar los logs del sistema con marcas de tiempo e iconos.
///
/// [symbol] define el icono a mostrar
///
String fechaD([String symbol = ' ']) {
  final now = DateTime.now();
  final timeStr = DateFormat('HH:mm:ss').format(now);

  final icon = symbol.substring(0, 1).toLowerCase();

  return '$timeStr -$icon ';
}

/// Formatea una fecha con hora en el idioma del usuario.
///
/// Ejemplos:
///   - Català:  `22 de febrer de 2026, a les 14:16:10`
///   - Español: `22 de febrero de 2026, a las 14:16:10`
///   - English: `22 of February of 2026, at 14:16:10`
String formatUploadDate(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toString();
  final String connector;
  switch (locale.split('_').first) {
    case 'ca':
      connector = 'a les';
      break;
    case 'en':
      connector = 'at';
      break;
    default: // es
      connector = 'a las';
  }
  return DateFormat(
    "dd 'de' MMMM 'de' y, '$connector' HH:mm:ss",
    locale,
  ).format(date);
}
