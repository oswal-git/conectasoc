import 'package:conectasoc/app/theme/app_theme.dart';
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
        '🧪 UserFriendlyErrorWidget: initState ✅ errorMessage: ${widget.errorMessage}');
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
        padding: AppTheme.paddingPage,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMissingIndexError
                  ? Icons.settings_suggest_outlined
                  : Icons.error_outline_rounded,
              size: 64,
              color: AppTheme.textSecondary.withAlpha(128),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              friendlyMessage,
              textAlign: TextAlign.center,
              style: AppTheme.errorMessage(context),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            if (widget.onRetry != null)
              FilledButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context).retry),
              ),
            const SizedBox(height: AppTheme.spaceSm),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                size: AppTheme.iconSizeSmall,
              ),
              label: Text(
                _isExpanded ? "Ocultar detalles" : "Ver detalles técnicos",
                style: AppTheme.toggleLabel,
              ),
            ),
            if (_isExpanded) ...[
              const SizedBox(height: AppTheme.spaceXs),
              Container(
                padding: AppTheme.paddingContainer,
                decoration: BoxDecoration(
                  color: AppTheme.inputBackground,
                  borderRadius: AppTheme.borderRadiusDefault,
                  border: Border.all(color: AppTheme.border),
                ),
                child: SelectableText(
                  widget.errorMessage,
                  style: AppTheme.errorDetail,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
