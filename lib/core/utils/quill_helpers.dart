import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' as quill;

/// Convierte una cadena JSON de Quill Delta a texto plano.
/// Es robusto contra JSON mal formado o saltos de línea literales.
String quillJsonToPlainText(String quillJson) {
  if (quillJson.isEmpty) return '';

  try {
    List<dynamic> jsonData = jsonDecode(quillJson);

    // Verificar si el documento termina con un salto de línea sin atributos
    if (jsonData.isNotEmpty) {
      final lastInsert = jsonData.last as Map<String, dynamic>;
      final lastInsertText = lastInsert['insert'] as String?;

      // Si no termina con \n sin atributos, añadirlo
      if (lastInsertText == null ||
          !lastInsertText.endsWith('\n') ||
          lastInsert.containsKey('attributes')) {
        jsonData.add({'insert': '\n'});
      }
    }

    final doc = quill.Document.fromJson(jsonData);
    return doc.toPlainText().trim();
  } catch (e) {
    // Si falla el parseo, devolvemos el texto original
    return quillJson;
  }
}
