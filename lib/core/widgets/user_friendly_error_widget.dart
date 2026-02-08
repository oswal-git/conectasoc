import 'package:flutter/material.dart';
import 'package:conectasoc/app/theme/app_colors.dart';
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
        padding: const EdgeInsets.all(24.0),
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
              color: AppColors.textSecondary.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              friendlyMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            if (widget.onRetry != null)
              FilledButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context).retry),
              ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 16,
              ),
              label: Text(
                _isExpanded ? "Ocultar detalles" : "Ver detalles técnicos",
                style: const TextStyle(fontSize: 12),
              ),
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  widget.errorMessage,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
