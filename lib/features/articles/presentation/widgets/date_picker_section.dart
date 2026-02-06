import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'date_picker_field.dart';

class DatePickerSection extends StatelessWidget {
  final bool isEnabled;
  final DateTime publishDate;
  final DateTime effectiveDate;
  final DateTime? expirationDate;
  final AppLocalizations l10n;

  const DatePickerSection({
    super.key,
    required this.isEnabled,
    required this.publishDate,
    required this.effectiveDate,
    this.expirationDate,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isEnabled,
      child: Column(
        children: [
          DatePickerField(
            label: l10n.publishDateLabel,
            selectedDate: publishDate,
            onDateSelected: (date) {
              context.read<ArticleEditBloc>().add(PublishDateChanged(date));
            },
          ),
          const SizedBox(height: 16),
          DatePickerField(
            label: l10n.effectiveDateLabel,
            selectedDate: effectiveDate,
            onDateSelected: (date) {
              context.read<ArticleEditBloc>().add(EffectiveDateChanged(date));
            },
          ),
          const SizedBox(height: 16),
          DatePickerField(
            label: l10n.expirationDateLabel,
            selectedDate: expirationDate,
            onDateSelected: (date) {
              context.read<ArticleEditBloc>().add(ExpirationDateChanged(date));
            },
            onClearDate: () {
              context
                  .read<ArticleEditBloc>()
                  .add(const ExpirationDateChanged(null));
            },
            isOptional: true,
          ),
        ],
      ),
    );
  }
}
