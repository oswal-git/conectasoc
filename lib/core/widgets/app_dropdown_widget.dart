// lib/shared/widgets/app_dropdown_widget.dart

import 'package:conectasoc/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Variante visual del dropdown.
///
/// - [normal]  → formularios: padding estándar, prefixIcon, validator
/// - [dense]   → filtros en barras / diálogos: compacto, texto pequeño
enum AppDropdownVariant { normal, dense }

/// Dropdown reutilizable con estilo unificado en toda la app.
///
/// Genérico en [T] para soportar tanto [String] como enums u otras clases.
///
/// Ejemplo básico (formulario):
/// ```dart
/// AppDropdownWidget<String>(
///   label: l10n.category,
///   value: _selectedId,
///   items: categories.map((c) => AppDropdownItem(value: c.id, label: c.name)).toList(),
///   onChanged: (v) => setState(() => _selectedId = v),
///   prefixIcon: const Icon(Icons.category),
///   validator: (v) => v == null ? 'Requerido' : null,
/// )
/// ```
///
/// Ejemplo compacto (filtro):
/// ```dart
/// AppDropdownWidget<String>(
///   label: l10n.category,
///   value: selectedCategoryId,
///   items: [
///     AppDropdownItem(value: null, label: '— ${l10n.category} —'),
///     ...categories.map((c) => AppDropdownItem(value: c.id, label: c.name)),
///   ],
///   onChanged: (v) => bloc.add(CategoryFilterChanged(v)),
///   variant: AppDropdownVariant.dense,
/// )

/// Par valor / etiqueta para el caso estándar.
///
/// Para items con widget personalizado (icono, etc.) usa [AppDropdownWidget.customItems].
class AppDropdownItem<T> {
  final T? value;
  final String label;

  const AppDropdownItem({required this.value, required this.label});
}

/// ```
class AppDropdownWidget<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<AppDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;

  /// Solo en variante [AppDropdownVariant.normal]
  final Widget? prefixIcon;

  /// Solo en variante [AppDropdownVariant.normal]
  final String? Function(T?)? validator;

  /// Texto de ayuda bajo el campo (variante normal)
  final String? helperText;
  final int? helperMaxLines;

  /// Permite items con widget personalizado (p.ej. icono + texto en ReadScope)
  final List<DropdownMenuItem<T>>? customItems;

  final AppDropdownVariant variant;

  final String? hint;

  /// Permite expandir el dropdown para ocupar todo el ancho disponible
  final bool isExpanded;
  final bool enabled;

  const AppDropdownWidget({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.items = const [],
    this.prefixIcon,
    this.validator,
    this.helperText,
    this.helperMaxLines,
    this.customItems,
    this.variant = AppDropdownVariant.normal,
    this.hint,
    this.isExpanded = true,
    this.enabled = true,
  }) : assert(
          items.length > 0 || customItems != null,
          'Provide either items or customItems',
        );

  @override
  Widget build(BuildContext context) {
    final isDense = variant == AppDropdownVariant.dense;

    final resolvedItems = customItems ??
        items.map((item) {
          return DropdownMenuItem<T>(
            value: item.value,
            child: Text(
              item.label,
              overflow: TextOverflow.ellipsis,
              style: isDense ? AppTheme.dropdownDenseItem : null,
            ),
          );
        }).toList();

    final decoration = isDense
        ? InputDecoration(
            labelText: label,
            isDense: true,
            enabled: enabled,
            border: const OutlineInputBorder(
              borderRadius: AppTheme.borderRadiusDefault,
            ),
            contentPadding: AppTheme.paddingDropdownDense,
          )
        : InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: prefixIcon,
            helperText: helperText,
            helperMaxLines: helperMaxLines,
            enabled: enabled,
          );

    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: isExpanded,
      decoration: decoration,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.normal,
          ),
      items: resolvedItems,
      onChanged: enabled ? onChanged : null,
      validator: isDense ? null : validator,
    );
  }
}
