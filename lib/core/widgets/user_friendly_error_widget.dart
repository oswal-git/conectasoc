import 'package:conectasoc/app/theme/theme.dart';
import 'package:conectasoc/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:conectasoc/l10n/app_localizations.dart';

/// Un widget para mostrar errores de forma amigable al usuario,
/// con opción de ver detalles técnicos para superadmins/desarrolladores.
class UserFriendlyErrorWidget extends StatefulWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  final bool showDetailsInitially;

  const UserFriendlyErrorWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
    this.showDetailsInitially = false,
  });

  @override
  State<UserFriendlyErrorWidget> createState() =>
      _UserFriendlyErrorWidgetState();
}

class _UserFriendlyErrorWidgetState extends State<UserFriendlyErrorWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.showDetailsInitially;
    debugPrint(
        '${fechaD('🧪')} UserFriendlyErrorWidget: initState ✅ errorMessage: ${widget.errorMessage}');
  }

  @override
  Widget build(BuildContext context) {
    // Detectamos si el error menciona un índice faltante de Firestore para dar un mensaje específico.
    final bool isMissingIndexError =
        widget.errorMessage.contains('failed-precondition') ||
            widget.errorMessage.contains('requires an index');

    String friendlyMessage = AppLocalizations.of(context).genericError;
    if (isMissingIndexError) {
      friendlyMessage =
          "Se requiere una configuración adicional en la base de datos.";
    }

    return Center(
      child: Padding(
        padding: AppSpacingTheme.paddingPage,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMissingIndexError
                  ? Icons.settings_suggest_outlined
                  : Icons.error_outline_rounded,
              size: 64,
              color: AppColors.textSecondary.withAlpha(128),
            ),
            AppSizedBoxTheme.fieldVerticalSeparator,
            Text(
              friendlyMessage,
              textAlign: TextAlign.center,
              style: AppTextStylesTheme.errorTextDetail(context),
            ),
            AppSizedBoxTheme.fieldVerticalDoubleSeparator,
            if (widget.onRetry != null)
              FilledButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context).retry),
              ),
            AppSizedBoxTheme.fieldVerticalSeparator,
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                size: AppIconsTheme.sizeSm,
              ),
              label: Text(
                _isExpanded ? "Ocultar detalles" : "Ver detalles técnicos",
                style: AppTextStylesTheme.labelSmall,
              ),
            ),
            if (_isExpanded) ...[
              AppSizedBoxTheme.fieldVerticalTinySeparator,
              Container(
                padding: AppSpacingTheme.paddingContainer,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadiusTheme.container,
                  border: Border.all(color: AppColors.border),
                ),
                child: SelectableText(
                  widget.errorMessage,
                  style: AppTextStylesTheme.errorTextDetail(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
