// 📁 scripts/migrate_colors.dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';

import 'color_mapping.dart';

/// 🚀 Script de migración de colores hardcoded → AppColors
///
/// ## Uso:
/// ```bash
/// # Dry run (solo ver cambios)
/// dart run scripts/migrate_colors.dart --dry-run
///
/// # Migración real (crea backups)
/// dart run scripts/migrate_colors.dart --migrate
///
/// # Migración con backup custom
/// dart run scripts/migrate_colors.dart --migrate --backup-dir=./backups
/// ```
class ColorMigrator {
  final String projectRoot;
  final Directory scanDir;
  final bool dryRun;
  final String? backupDir;

  // Estadísticas
  int _filesScanned = 0;
  int _filesModified = 0;
  int _colorsReplaced = 0;
  final Map<String, int> _colorUsageCount = {};
  final List<String> _unmappedColors = [];

  static const List<String> _excludedDirs = [
    '/test/',
    '/tests/',
    '/build/',
    '/.dart_tool/',
    '/.flutter-plugins/',
    '/.packages/',
    '/.pub-cache/',
    '/ios/',
    '/android/',
    '/web/',
    '/windows/',
    '/linux/',
    '/macos/',
    '/scripts/',
    '/packages/',
    '/.git/',
    '/node_modules/',
  ];

  static const List<String> _excludedFiles = [
    'pubspec.lock',
    '.packages',
    '.flutter-plugins',
  ];

  ColorMigrator({
    required this.projectRoot,
    required this.scanDir,
    this.dryRun = true,
    this.backupDir,
  });

  Future<void> run() async {
    debugPrint('🎨 Color Migration Tool');
    debugPrint('═' * 60);
    debugPrint('📁 Project root: $projectRoot');
    debugPrint('🔍 Scan directory: ${scanDir.path}');
    debugPrint('🔍 Mode: ${dryRun ? "DRY RUN (no changes)" : "MIGRATION"}');
    debugPrint('🚫 Excluded dirs: ${_excludedDirs.length}');
    debugPrint('🚫 Excluded files: ${_excludedFiles.length}');
    debugPrint('═' * 60);
    debugPrint('');

    // ✅ VALIDACIÓN: Asegurar que scanDir existe
    // if (!await scanDir.exists()) {
    //   debugPrint('❌ Error: Scan directory does not exist: ${scanDir.path}');
    //   exit(1);
    // }

    // // ✅ VALIDACIÓN: Asegurar que scanDir está dentro de projectRoot
    // if (!scanDir.path.startsWith(projectRoot)) {
    //   debugPrint('❌ Error: Scan directory must be within project root');
    //   debugPrint('   Scan dir: ${scanDir.path}');
    //   debugPrint('   Project root: $projectRoot');
    //   exit(1);
    // }

    // await _scanDirectory(scanDir);

    _printReport();
  }

  Future<void> _scanDirectory(Directory dir) async {
    // ✅ VALIDACIÓN: Verificar si el directorio debe ser excluido
    if (_shouldExcludeDir(dir.path)) {
      debugPrint('  🚫 Skipping excluded directory: ${dir.path}');
      return;
    }

    try {
      await for (final entity
          in dir.list(recursive: true, followLinks: false)) {
        // ✅ VALIDACIÓN: Solo procesar archivos .dart
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }

        // ✅ VALIDACIÓN: Verificar si el archivo debe ser excluido
        if (_shouldExcludeFile(entity.path)) {
          continue;
        }

        // ✅ VALIDACIÓN: Excluir directorio theme/ (no migrar el sistema de temas)
        if (entity.path.contains('/theme/')) {
          debugPrint('  🎨 Skipping theme file: ${entity.path}');
          continue;
        }

        // ✅ VALIDACIÓN: Excluir directorio scripts/
        if (entity.path.contains('/scripts/')) {
          continue;
        }

        await _processFile(entity);
      }
    } catch (e) {
      debugPrint('  ⚠️  Error scanning ${dir.path}: $e');
    }
  }

  // ✅ NUEVO: Verificar si un directorio debe ser excluido
  bool _shouldExcludeDir(String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    return _excludedDirs.any((excluded) => normalizedPath.contains(excluded));
  }

  // ✅ NUEVO: Verificar si un archivo debe ser excluido
  bool _shouldExcludeFile(String path) {
    final fileName = path.split('/').last;
    return _excludedFiles.contains(fileName);
  }

  Future<void> _processFile(File file) async {
    _filesScanned++;

    final content = await file.readAsString();
    final originalContent = content;

    String modifiedContent = content;

    // ── 1. Reemplazar Color(0xFF...) ───────────────────
    final hexColorRegex = RegExp(r'Color\(0x([0-9A-Fa-f]+)\)');
    final hexMatches = hexColorRegex.allMatches(modifiedContent);

    for (final match in hexMatches) {
      final hexValue = '0x${match.group(1)}';
      final fullMatch = match.group(0)!;

      final appColorsProp = ColorMapping.getAppColorsProperty(hexValue);

      if (appColorsProp != null) {
        final replacement = 'AppColors.of(context).$appColorsProp';
        modifiedContent = modifiedContent.replaceFirst(fullMatch, replacement);
        _colorsReplaced++;
        _colorUsageCount[appColorsProp] =
            (_colorUsageCount[appColorsProp] ?? 0) + 1;

        if (!dryRun) {
          debugPrint('  ✅ ${file.path}: $fullMatch → $replacement');
        } else {
          debugPrint('  🔍 ${file.path}: $fullMatch → $replacement');
        }
      } else {
        if (!_unmappedColors.contains(hexValue)) {
          _unmappedColors.add(hexValue);
        }
      }
    }

    // ── 2. Reemplazar Colors.xxx ──────────────────────
    final materialColorRegex = RegExp(
        r'Colors\.(white|black|black87|black54|black45|black38|black26|black12|white70|white60|white54|white38|white24|white12|red|green|orange|blue|grey(?:\.shade\d+)?)');
    final materialMatches = materialColorRegex.allMatches(modifiedContent);

    for (final match in materialMatches) {
      final materialColor = match.group(0)!;
      final appColorsProp =
          ColorMapping.getMaterialColorProperty(materialColor);

      if (appColorsProp != null) {
        // Evitar reemplazar dentro de strings o comentarios
        final beforeMatch = modifiedContent.substring(0, match.start);
        if (beforeMatch.endsWith("'") ||
            beforeMatch.endsWith('"') ||
            beforeMatch.endsWith('//')) {
          continue;
        }

        final replacement = 'AppColors.of(context).$appColorsProp';
        modifiedContent =
            modifiedContent.replaceFirst(materialColor, replacement);
        _colorsReplaced++;
        _colorUsageCount[appColorsProp] =
            (_colorUsageCount[appColorsProp] ?? 0) + 1;

        if (!dryRun) {
          debugPrint('  ✅ ${file.path}: $materialColor → $replacement');
        } else {
          debugPrint('  🔍 ${file.path}: $materialColor → $replacement');
        }
      }
    }

    // ── 3. Guardar cambios (si no es dry run) ─────────
    if (modifiedContent != originalContent && !dryRun) {
      // Crear backup
      if (backupDir != null) {
        await _createBackup(file);
      }

      // Escribir archivo modificado
      await file.writeAsString(modifiedContent);
      _filesModified++;
    } else if (modifiedContent != originalContent && dryRun) {
      debugPrint(
          '  📝 ${file.path}: ${_countDifferences(originalContent, modifiedContent)} cambios pendientes');
    }
  }

  Future<void> _createBackup(File file) async {
    final backupPath = backupDir ?? '$projectRoot/backups';
    final backupDirObj = Directory(backupPath);

    if (!await backupDirObj.exists()) {
      await backupDirObj.create(recursive: true);
    }

    final relativePath = file.path.replaceFirst('$projectRoot/', '');
    final backupFile = File('$backupPath/$relativePath');

    await backupFile.parent.create(recursive: true);
    await file.copy(backupFile.path);
  }

  int _countDifferences(String original, String modified) {
    return modified.length - original.length;
  }

  void _printReport() {
    debugPrint('');
    debugPrint('═' * 60);
    debugPrint('📊 MIGRATION REPORT');
    debugPrint('═' * 60);
    debugPrint('📁 Files scanned: $_filesScanned');
    debugPrint('📝 Files modified: $_filesModified');
    debugPrint('🎨 Colors replaced: $_colorsReplaced');
    debugPrint('');

    if (_colorUsageCount.isNotEmpty) {
      debugPrint('📈 TOP AppColors PROPERTIES USED:');
      debugPrint('─' * 40);
      final sorted = _colorUsageCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in sorted.take(10)) {
        debugPrint('  • ${entry.key}: ${entry.value} veces');
      }
      debugPrint('');
    }

    if (_unmappedColors.isNotEmpty) {
      debugPrint('⚠️  UNMAPPED COLORS (manual review needed):');
      debugPrint('─' * 40);
      for (final color in _unmappedColors.take(20)) {
        debugPrint('  • $color');
      }
      if (_unmappedColors.length > 20) {
        debugPrint('  ... and ${_unmappedColors.length - 20} more');
      }
      debugPrint('');
      debugPrint(
          '  💡 Add these to ColorMapping.map in scripts/color_mapping.dart');
      debugPrint('');
    }

    if (dryRun) {
      debugPrint('🔍 This was a DRY RUN. No files were modified.');
      debugPrint('');
      debugPrint('✅ To apply changes, run:');
      debugPrint('   dart run scripts/migrate_colors.dart --migrate');
    } else {
      debugPrint('✅ Migration completed!');
      debugPrint('');
      debugPrint('📋 NEXT STEPS:');
      debugPrint('  1. Review changed files with git diff');
      debugPrint(
          '  2. Ensure BuildContext is available where AppColors.of(context) is used');
      debugPrint('  3. Run flutter test to verify no regressions');
      debugPrint(
          '  4. Commit changes with message: "refactor: migrate colors to AppColors"');
    }

    debugPrint('═' * 60);
  }
}

// ════════════════════════════════════════════════════
//  MAIN ENTRY POINT
// ════════════════════════════════════════════════════

void main(List<String> args) async {
  // ✅ AHORA (correcto):

  final projectRoot = Directory.current.path;
  final libDir = Directory('$projectRoot/lib');

  // 🔒 VALIDACIÓN: Asegurar que lib/ existe
  if (!await libDir.exists()) {
    debugPrint('❌ Error: lib/ directory not found at $libDir');
    debugPrint('');
    debugPrint(
        '💡 Asegúrate de ejecutar el script desde la raíz del proyecto Flutter:');
    debugPrint('   cd /ruta/a/tu/proyecto');
    debugPrint('   dart run scripts/migrate_colors.dart --dry-run');
    exit(1);
  }

  // 🔒 VALIDACIÓN: Confirmar que es un proyecto Flutter
  final pubspecFile = File('$projectRoot/pubspec.yaml');
  if (!await pubspecFile.exists()) {
    debugPrint('❌ Error: pubspec.yaml not found at $projectRoot');
    debugPrint('');
    debugPrint('💡 Ejecuta el script desde la raíz del proyecto Flutter');
    exit(1);
  }

  // ✅ PASO 3: Parsear argumentos (ANTES de usar las variables)
  final dryRun = !args.contains('--migrate');
  final backupDir = args.contains('--backup-dir')
      ? args[args.indexOf('--backup-dir') + 1]
      : null;

  debugPrint('✅ Project root: $projectRoot');
  debugPrint('✅ Scanning directory: ${libDir.path}');
  debugPrint('');

  final migrator = ColorMigrator(
    projectRoot: projectRoot,
    scanDir: libDir, // ✅ Explicitamente pasar lib/ como directorio a escanear
    dryRun: dryRun,
    backupDir: backupDir,
  );

  // await migrator.run();
}
