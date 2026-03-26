// 📁 scripts/migrate_colors.dart
// ✅ VERSIÓN CON LOGGING DETALLADO PARA DEBUG

import 'dart:io';
import 'package:flutter/material.dart';

import 'color_mapping.dart';

// ════════════════════════════════════════════
//  NIVELES DE LOGGING
// ════════════════════════════════════════════

enum LogLevel {
  silent, // 0: Sin logs
  error, // 1: Solo errores
  warning, // 2: Errores + warnings
  info, // 3: Errores + warnings + info (default)
  verbose, // 4: Todo + detalles
  debug, // 5: Todo + debug interno
}

class Logger {
  static LogLevel level = LogLevel.info;
  static final List<String> _logs = [];
  static final Stopwatch _stopwatch = Stopwatch();

  static void startTimer() => _stopwatch.start();
  static String get elapsed => _stopwatch.elapsed.inSeconds.toString();

  static void _log(LogLevel logLevel, String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final levelName = logLevel.name.toUpperCase().padRight(5);
    final log = '[$timestamp] [$levelName] $message';
    _logs.add(log);

    if (_shouldPrint(logLevel)) {
      debugPrint(log);
    }
  }

  static bool _shouldPrint(LogLevel logLevel) {
    return logLevel.index <= level.index;
  }

  static void error(String msg) => _log(LogLevel.error, msg);
  static void warn(String msg) => _log(LogLevel.warning, msg);
  static void info(String msg) => _log(LogLevel.info, msg);
  static void verbose(String msg) => _log(LogLevel.verbose, msg);
  static void debug(String msg) => _log(LogLevel.debug, msg);

  static void success(String msg) => _log(LogLevel.info, '✅ $msg');
  static void section(String title) {
    _log(LogLevel.info, '');
    _log(LogLevel.info, '═' * 60);
    _log(LogLevel.info, title);
    _log(LogLevel.info, '═' * 60);
  }

  static void saveToFile(String path) {
    try {
      File(path).writeAsStringSync(_logs.join('\n'));
      debugPrint('📄 Log guardado en: $path');
    } catch (e) {
      debugPrint('❌ Error guardando log: $e');
    }
  }

  static void clear() {
    _logs.clear();
    _stopwatch.reset();
  }
}

// ════════════════════════════════════════════
//  MIGRATOR CON LOGGING
// ════════════════════════════════════════════

class ColorMigrator {
  final String projectRoot;
  final Directory scanDir;
  final bool dryRun;
  final String? backupDir;
  final LogLevel logLevel;

  // Estadísticas
  int _filesScanned = 0;
  int _filesModified = 0;
  int _filesSkipped = 0;
  int _colorsReplaced = 0;
  int _errors = 0;
  final Map<String, int> _colorUsageCount = {};
  final List<String> _unmappedColors = [];
  final List<String> _errorFiles = [];
  final Map<String, List<String>> _fileChanges = {};

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

  ColorMigrator({
    required this.projectRoot,
    required this.scanDir,
    this.dryRun = true,
    this.backupDir,
    this.logLevel = LogLevel.info,
  }) {
    Logger.level = logLevel;
  }

  Future<void> run() async {
    Logger.startTimer();

    Logger.section('🎨 COLOR MIGRATION TOOL');
    Logger.info('📁 Project root: $projectRoot');
    Logger.info('🔍 Scan directory: ${scanDir.path}');
    Logger.info('🔍 Mode: ${dryRun ? "DRY RUN (no changes)" : "MIGRATION"}');
    Logger.info('📊 Log level: ${logLevel.name.toUpperCase()}');
    Logger.info('🚫 Excluded dirs: ${_excludedDirs.length}');
    Logger.info(
        '⏱️  Start time: ${DateTime.now().toString().substring(0, 19)}');
    Logger.info('═' * 60);

    // ✅ VALIDACIONES
    if (!await scanDir.exists()) {
      Logger.error('❌ Scan directory does not exist: ${scanDir.path}');
      exit(1);
    }

    if (!scanDir.path.startsWith(projectRoot)) {
      Logger.error('❌ Scan directory must be within project root');
      exit(1);
    }

    final pubspecFile = File('$projectRoot/pubspec.yaml');
    if (!await pubspecFile.exists()) {
      Logger.error('❌ pubspec.yaml not found at $projectRoot');
      exit(1);
    }

    Logger.success('Validations passed');
    Logger.info('');

    // ✅ ESCANEO
    await _scanDirectory(scanDir);

    // ✅ REPORTE
    _printReport();
  }

  Future<void> _scanDirectory(Directory dir) async {
    Logger.debug('📂 Entering directory: ${dir.path}');

    if (_shouldExcludeDir(dir.path)) {
      Logger.verbose('🚫 Skipping excluded directory: ${dir.path}');
      _filesSkipped++;
      return;
    }

    try {
      final entities = await dir.list(followLinks: false).toList();
      Logger.debug('📁 Found ${entities.length} entities in ${dir.path}');

      for (final entity in entities) {
        if (entity is Directory) {
          await _scanDirectory(entity);
        } else if (entity is File) {
          await _processFile(entity);
        }
      }
    } catch (e) {
      Logger.error('⚠️  Error scanning ${dir.path}: $e');
      _errors++;
    }
  }

  bool _shouldExcludeDir(String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    return _excludedDirs.any((excluded) => normalizedPath.contains(excluded));
  }

  Future<void> _processFile(File file) async {
    Logger.debug('📄 Processing file: ${file.path}');

    _filesScanned++;

    // ✅ Progress indicator cada 50 archivos
    if (_filesScanned % 50 == 0) {
      Logger.info(
          '📊 Progress: $_filesScanned files scanned, $_colorsReplaced colors replaced...');
    }

    try {
      final content = await file.readAsString();
      final originalContent = content;

      Logger.verbose('  📏 File size: ${content.length} characters');

      String modifiedContent = content;
      int fileReplacements = 0;
      final List<String> fileChanges = [];

      // ── 1. Reemplazar Color(0xFF...) ───────────────────
      Logger.debug('  🔍 Searching for Color(0x...) patterns...');

      final hexColorRegex = RegExp(r'Color\(0x([0-9A-Fa-f]+)\)');
      final hexMatches = hexColorRegex.allMatches(modifiedContent);

      Logger.debug('  📊 Found ${hexMatches.length} Color(0x...) matches');

      for (final match in hexMatches) {
        final hexValue = '0x${match.group(1)}';
        final fullMatch = match.group(0)!;

        Logger.verbose('    🎨 Found: $fullMatch at position ${match.start}');

        final appColorsProp =
            ColorMapping.getContextualProperty(hexValue, file.path);

        if (appColorsProp != null) {
          final replacement = 'AppColors.of(context).$appColorsProp';
          modifiedContent =
              modifiedContent.replaceFirst(fullMatch, replacement);

          _colorsReplaced++;
          fileReplacements++;
          _colorUsageCount[appColorsProp] =
              (_colorUsageCount[appColorsProp] ?? 0) + 1;

          fileChanges.add('$fullMatch → $replacement');

          Logger.verbose('    ✅ Replaced: $appColorsProp');
        } else {
          if (!_unmappedColors.contains(hexValue)) {
            _unmappedColors.add(hexValue);
            Logger.verbose('    ⚠️  Unmapped color: $hexValue');
          }
        }
      }

      // ── 2. Reemplazar Colors.xxx ──────────────────────
      Logger.debug('  🔍 Searching for Colors.xxx patterns...');

      final materialColorRegex = RegExp(
        r'Colors\.(white|black|black87|black54|black45|black38|black26|black12|white70|white60|white54|white38|white24|white12|red|green|orange|blue|grey(?:\.shade\d+)?)',
      );
      final materialMatches = materialColorRegex.allMatches(modifiedContent);

      Logger.debug('  📊 Found ${materialMatches.length} Colors.xxx matches');

      for (final match in materialMatches) {
        final materialColor = match.group(0)!;
        final appColorsProp =
            ColorMapping.getMaterialColorProperty(materialColor);

        if (appColorsProp != null) {
          final beforeMatch = modifiedContent.substring(0, match.start);

          // Evitar strings y comentarios
          if (beforeMatch.endsWith("'") ||
              beforeMatch.endsWith('"') ||
              beforeMatch.endsWith('//')) {
            Logger.verbose(
                '    ⏭️  Skipped (in string/comment): $materialColor');
            continue;
          }

          final replacement = 'AppColors.of(context).$appColorsProp';
          modifiedContent =
              modifiedContent.replaceFirst(materialColor, replacement);

          _colorsReplaced++;
          fileReplacements++;
          _colorUsageCount[appColorsProp] =
              (_colorUsageCount[appColorsProp] ?? 0) + 1;

          fileChanges.add('$materialColor → $replacement');

          Logger.verbose('    ✅ Replaced: $materialColor → $appColorsProp');
        }
      }

      // ── 3. Guardar cambios ────────────────────────────
      if (modifiedContent != originalContent) {
        Logger.verbose('  📝 File has $fileReplacements changes');

        if (!dryRun) {
          if (backupDir != null) {
            await _createBackup(file);
          }

          await file.writeAsString(modifiedContent);
          _filesModified++;
          _fileChanges[file.path] = fileChanges;

          Logger.info('  ✅ Modified: ${file.path} ($fileReplacements changes)');
        } else {
          _fileChanges[file.path] = fileChanges;
          Logger.info(
              '  📝 Would modify: ${file.path} ($fileReplacements changes)');
        }
      } else {
        Logger.debug('  ⏭️  No changes needed: ${file.path}');
      }
    } catch (e, stackTrace) {
      Logger.error('  ❌ Error processing ${file.path}: $e');
      Logger.debug('  Stack trace: $stackTrace');
      _errors++;
      _errorFiles.add('${file.path}: $e');
    }
  }

  Future<void> _createBackup(File file) async {
    Logger.debug('  💾 Creating backup for: ${file.path}');

    try {
      final backupPath = backupDir ?? '$projectRoot/backups';
      final backupDirObj = Directory(backupPath);

      if (!await backupDirObj.exists()) {
        await backupDirObj.create(recursive: true);
        Logger.debug('  📁 Created backup directory: $backupPath');
      }

      final relativePath = file.path.replaceFirst('$projectRoot/', '');
      final backupFile = File('$backupPath/$relativePath');

      await backupFile.parent.create(recursive: true);
      await file.copy(backupFile.path);

      Logger.verbose('  ✅ Backup created: ${backupFile.path}');
    } catch (e) {
      Logger.error('  ❌ Error creating backup: $e');
    }
  }

  void _printReport() {
    Logger.section('📊 MIGRATION REPORT');

    final elapsedSeconds = Logger.elapsed;

    Logger.info('⏱️  Elapsed time: ${elapsedSeconds}s');
    Logger.info('📁 Files scanned: $_filesScanned');
    Logger.info('📝 Files modified: $_filesModified');
    Logger.info('🚫 Files skipped: $_filesSkipped');
    Logger.info('🎨 Colors replaced: $_colorsReplaced');
    Logger.info('❌ Errors: $_errors');
    Logger.info('');

    if (_filesScanned > 0) {
      final avgReplacements = _colorsReplaced / _filesScanned;
      Logger.info(
          '📈 Average replacements per file: ${avgReplacements.toStringAsFixed(2)}');
      Logger.info(
          '📈 Files with changes: ${((_filesModified / _filesScanned) * 100).toStringAsFixed(1)}%');
    }
    Logger.info('');

    // TOP AppColors PROPERTIES
    if (_colorUsageCount.isNotEmpty) {
      Logger.section('📈 TOP AppColors PROPERTIES USED');
      final sorted = _colorUsageCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in sorted.take(15)) {
        final bar = '█' * ((entry.value / 10).ceil());
        Logger.info(
            '  ${entry.key.padRight(20)} ${entry.value.toString().padLeft(4)} $bar');
      }
      Logger.info('');
    }

    // UNMAPPED COLORS
    if (_unmappedColors.isNotEmpty) {
      Logger.section('⚠️  UNMAPPED COLORS (manual review needed)');
      for (final color in _unmappedColors.take(20)) {
        Logger.info('  • $color');
      }
      if (_unmappedColors.length > 20) {
        Logger.info('  ... and ${_unmappedColors.length - 20} more');
      }
      Logger.info('');
      Logger.info(
          '  💡 Add these to ColorMapping.map in scripts/color_mapping.dart');
      Logger.info('');
    }

    // AMBIGUOUS COLORS
    final ambiguous = ColorMapping.getAmbiguousColors();
    if (ambiguous.isNotEmpty) {
      Logger.section('⚠️  AMBIGUOUS COLORS (multiple semantic uses)');
      for (final entry in ambiguous.entries) {
        Logger.info('  • ${entry.key}: ${entry.value.join(", ")}');
      }
      Logger.info('');
      Logger.info(
          '  💡 Review these manually - context determines the correct property');
      Logger.info('');
    }

    // ERRORS
    if (_errors > 0) {
      Logger.section('❌ ERRORS ($_errors total)');
      for (final error in _errorFiles.take(10)) {
        Logger.info('  • $error');
      }
      if (_errorFiles.length > 10) {
        Logger.info('  ... and ${_errorFiles.length - 10} more');
      }
      Logger.info('');
    }

    // FINAL STATUS
    Logger.section('🏁 FINAL STATUS');

    if (dryRun) {
      Logger.info('🔍 This was a DRY RUN. No files were modified.');
      Logger.info('');
      Logger.info('✅ To apply changes, run:');
      Logger.info('   dart run scripts/migrate_colors.dart --migrate');
    } else {
      Logger.success('Migration completed!');
      Logger.info('');
      Logger.info('📋 NEXT STEPS:');
      Logger.info('  1. Review changed files: git diff');
      Logger.info('  2. Check for BuildContext availability');
      Logger.info('  3. Run: flutter analyze');
      Logger.info('  4. Run: flutter test');
      Logger.info('  5. Run: flutter run');
      Logger.info(
          '  6. Commit: git commit -m "refactor: migrate colors to AppColors"');
    }

    Logger.info('');
    Logger.info('═' * 60);
    Logger.info('🏁 End time: ${DateTime.now().toString().substring(0, 19)}');
    Logger.info('═' * 60);

    // Guardar log si es verbose o debug
    if (Logger.level.index >= LogLevel.verbose.index) {
      final logPath =
          '$projectRoot/migration_log_${DateTime.now().millisecondsSinceEpoch}.txt';
      Logger.saveToFile(logPath);
    }
  }
}

// ════════════════════════════════════════════════════
//  MAIN ENTRY POINT
// ════════════════════════════════════════════════════

void main(List<String> args) async {
  // ✅ Parsear argumentos
  final projectRoot = Directory.current.path;
  final libDir = Directory('$projectRoot/lib');

  final dryRun = !args.contains('--migrate');
  final verbose = args.contains('--verbose') || args.contains('-v');
  final debug = args.contains('--debug') || args.contains('-d');
  final silent = args.contains('--silent') || args.contains('-s');
  final backupDir = args.contains('--backup-dir')
      ? args[args.indexOf('--backup-dir') + 1]
      : null;
  final saveLog = args.contains('--save-log');

  // ✅ Determinar log level
  LogLevel logLevel = LogLevel.info;
  if (silent) logLevel = LogLevel.silent;
  if (verbose) logLevel = LogLevel.verbose;
  if (debug) logLevel = LogLevel.debug;

  Logger.level = logLevel;

  // ✅ Validaciones
  if (!await libDir.exists()) {
    Logger.error('❌ Error: lib/ directory not found at $libDir');
    exit(1);
  }

  final pubspecFile = File('$projectRoot/pubspec.yaml');
  if (!await pubspecFile.exists()) {
    Logger.error('❌ Error: pubspec.yaml not found at $projectRoot');
    exit(1);
  }

  // ✅ Confirmación interactiva
  if (!dryRun && !silent) {
    debugPrint('');
    debugPrint('⚠️  WARNING: This will modify files in ${libDir.path}');
    debugPrint('');
    debugPrint('Type "YES" to confirm: ');
    final confirm = stdin.readLineSync();

    if (confirm != 'YES') {
      Logger.info('❌ Migration cancelled');
      exit(0);
    }
  }

  // ✅ Ejecutar migrator
  final migrator = ColorMigrator(
    projectRoot: projectRoot,
    scanDir: libDir,
    dryRun: dryRun,
    backupDir: backupDir,
    logLevel: logLevel,
  );

  await migrator.run();

  // ✅ Guardar log si se solicitó
  if (saveLog) {
    final logPath =
        '$projectRoot/migration_log_${DateTime.now().millisecondsSinceEpoch}.txt';
    Logger.saveToFile(logPath);
  }
}
