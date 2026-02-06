import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:conectasoc/l10n/app_localizations.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final Function()? onClearDate;
  final bool isOptional;

  const DatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.onClearDate,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      title: Text(label),
      subtitle: Text(selectedDate != null
          ? DateFormat.yMMMd(l10n.localeName).format(selectedDate!)
          : ''),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOptional && onClearDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: onClearDate,
            ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                onDateSelected(date);
              }
            },
          ),
        ],
      ),
    );
  }
}
