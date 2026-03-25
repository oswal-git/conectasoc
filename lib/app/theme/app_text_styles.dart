// 📁 lib/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  const AppTextStyles._();

  // ════════════════════════════════════════════
  //  TEXT THEME OVERRIDES
  // ════════════════════════════════════════════

  static TextTheme get light {
    final colors = AppColors.light();

    return TextTheme(
      headlineLarge:
          TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary),
      headlineMedium:
          TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary),
      headlineSmall:
          TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary),
      titleLarge:
          TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary),
      titleMedium:
          TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary),
      titleSmall:
          TextStyle(fontWeight: FontWeight.w500, color: colors.textPrimary),
      bodyLarge: TextStyle(color: colors.textPrimary),
      bodyMedium: TextStyle(color: colors.textSecondary),
      bodySmall: TextStyle(color: colors.textSecondary),
      labelLarge: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: colors.textPrimary),
      labelMedium: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: colors.textPrimary),
      labelSmall: TextStyle(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: colors.textSecondary),
    );
  }

  static TextTheme get dark {
    final colors = AppColors.dark();

    return TextTheme(
      headlineLarge:
          TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary),
      headlineMedium:
          TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary),
      headlineSmall:
          TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary),
      titleLarge:
          TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary),
      titleMedium:
          TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary),
      titleSmall:
          TextStyle(fontWeight: FontWeight.w500, color: colors.textPrimary),
      bodyLarge: TextStyle(color: colors.textPrimary),
      bodyMedium: TextStyle(color: colors.textSecondary),
      bodySmall: TextStyle(color: colors.textSecondary),
      labelLarge: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: colors.textPrimary),
      labelMedium: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: colors.textPrimary),
      labelSmall: TextStyle(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: colors.textSecondary),
    );
  }

  // ════════════════════════════════════════════
  //  SEMANTIC STYLES (usan AppColors)
  // ════════════════════════════════════════════

  /// 🔹 Hint / Placeholder
  static const hint = TextStyle(
    fontSize: 14,
    color:
        Color(0xFF7E7D7D), // ⚠️ TODO: migrar a AppColors.of(context).textHint
  );

  static TextStyle hintThemed(BuildContext context) {
    final colors = AppColors.of(context);
    return TextStyle(
      fontSize: 14,
      color: colors.textHint, // ✅ Usa AppColors
    );
  }

  /// 🔹 Splash / Welcome
  static const splashTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const splashSubtitle = TextStyle(
    fontSize: 16,
    color: Colors.white70,
  );

  /// 🔹 Botones
  static const buttonLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  /// 🔹 Banners (usan AppColors)
  static TextStyle infoBannerTitle(BuildContext context) => TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.of(context).infoTextTitle,
      );

  static TextStyle infoBannerBody(BuildContext context) => TextStyle(
        fontSize: 13,
        color: AppColors.of(context).infoTextBody,
      );

  static TextStyle warningBannerBody(BuildContext context) => TextStyle(
        fontSize: 13,
        color:
            AppColors.of(context).neutralText, // ⚠️ TODO: agregar a AppColors
      );

  /// 🔹 Cards
  static const cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static TextStyle cardDescription(BuildContext context) => TextStyle(
        fontSize: 12,
        color: AppColors.of(context).textSecondary,
      );

  /// 🔹 Captions
  static TextStyle caption(BuildContext context) => TextStyle(
        fontSize: 13,
        color: AppColors.of(context).textSecondary,
      );

  static TextStyle drawerSectionLabel(BuildContext context) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.of(context).textSecondary,
        letterSpacing: 0.8,
      );

  /// 🔹 Errores
  static TextStyle errorDetail(BuildContext context) => TextStyle(
        fontFamily: 'monospace',
        fontSize: 11,
        color: AppColors.of(context).errorText,
      );

  static const dropdownDenseItem = TextStyle(fontSize: 13);
  static const toggleLabel = TextStyle(fontSize: 12);

  /// 🔹 Listas
  static const listCaptionTitle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
  );

  static const listItemTitle = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 14,
  );

  /// 🔹 Acciones destructivas
  static TextStyle destructiveAction(BuildContext context) => TextStyle(
        color: AppColors.of(context).errorText,
      );

  // ════════════════════════════════════════════
  //  DYNAMIC SEMANTIC STYLES
  // ════════════════════════════════════════════

  static TextStyle loginTitle(BuildContext context) =>
      Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ) ??
      const TextStyle(fontSize: 32, fontWeight: FontWeight.w700);

  static TextStyle loginSubtitle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.of(context).textSecondary,
          ) ??
      const TextStyle(fontSize: 16);

  static const loginDividerLabel =
      TextStyle(color: Color(0xFF757575)); // ⚠️ TODO: migrar
  static const loginSecondaryLink =
      TextStyle(fontStyle: FontStyle.italic, fontSize: 14);

  static TextStyle articleTitle(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24) ??
      const TextStyle(fontSize: 24, fontWeight: FontWeight.w700);

  static TextStyle articleAbstract(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 12,
            height: 1.3,
            color: AppColors.of(context).textSecondary,
          ) ??
      const TextStyle(fontSize: 12, height: 1.3);

  static TextStyle articleCategory(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: Theme.of(context).colorScheme.primary,
          ) ??
      const TextStyle(fontSize: 10);

  static TextStyle articleBody(BuildContext context) =>
      Theme.of(context)
          .textTheme
          .bodyLarge
          ?.copyWith(fontSize: 14, height: 1.5) ??
      const TextStyle(fontSize: 14, height: 1.5);

  static TextStyle articleMeta(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12);

  static TextStyle articleFooter(BuildContext context) =>
      Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(fontStyle: FontStyle.italic) ??
      const TextStyle(fontSize: 12, fontStyle: FontStyle.italic);

  static TextStyle documentFileName(BuildContext context) =>
      Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w700) ??
      const TextStyle(fontWeight: FontWeight.w700);

  static TextStyle documentExtension(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.of(context).textSecondary,
          ) ??
      const TextStyle(color: Color(0xFF757575)); // ⚠️ TODO: migrar

  static TextStyle documentDescription(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.of(context).textSecondary,
          ) ??
      const TextStyle(color: Color(0xFF757575)); // ⚠️ TODO: migrar

  static TextStyle labelField(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ) ??
      const TextStyle(fontSize: 14);

  static TextStyle titleField(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.of(context).textSecondary,
          ) ??
      const TextStyle(fontSize: 14);

  static TextStyle searchFieldText(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ) ??
      const TextStyle(fontSize: 16);

  static TextStyle sectionTitle(BuildContext context) =>
      Theme.of(context).textTheme.headlineSmall ??
      const TextStyle(fontSize: 24, fontWeight: FontWeight.w600);

  static TextStyle errorMessage(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ) ??
      TextStyle(color: Theme.of(context).colorScheme.error);

  // ════════════════════════════════════════════
  //  HELPERS
  // ════════════════════════════════════════════

  static TextStyle asHint(TextStyle base, BuildContext context) =>
      base.copyWith(
        color: AppColors.of(context).textHint,
        fontStyle: FontStyle.italic,
      );

  static TextStyle asDisabled(TextStyle base, BuildContext context) =>
      base.copyWith(
        color: AppColors.of(context).textDisabled,
        fontWeight: FontWeight.normal,
      );

  static TextStyle withTextScaler(
    BuildContext context,
    TextStyle base, {
    double maxScaleFactor = 1.3,
  }) {
    final scaler =
        MediaQuery.textScalerOf(context).clamp(maxScaleFactor: maxScaleFactor);
    return base.apply(fontSizeFactor: scaler.scale(1.0));
  }
}
