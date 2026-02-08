import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';
import 'package:conectasoc/l10n/app_localizations.dart';

class StatusDropdownSection extends StatelessWidget {
  final ArticleStatus status;
  final bool isArticleValid;
  final AppLocalizations l10n;

  const StatusDropdownSection({
    super.key,
    required this.status,
    required this.isArticleValid,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ArticleStatus>(
      initialValue: status,
      decoration: InputDecoration(labelText: l10n.articleStatus),
      items: ArticleStatus.values.map((statusItem) {
        String statusText;
        switch (statusItem) {
          case ArticleStatus.redaccion:
            statusText = l10n.statusRedaccion;
            break;
          case ArticleStatus.publicado:
            statusText = l10n.statusPublicado;
            break;
          case ArticleStatus.revision:
            statusText = l10n.statusRevision;
            break;
          case ArticleStatus.expirado:
            statusText = l10n.statusExpirado;
            break;
          case ArticleStatus.anulado:
            statusText = l10n.statusAnulado;
            break;
          case ArticleStatus.notificar:
            statusText = l10n.statusNotificar;
            break;
        }
        return DropdownMenuItem(
          value: statusItem,
          enabled: isArticleValid ||
              statusItem == ArticleStatus.redaccion ||
              statusItem == ArticleStatus.anulado,
          child: Text(statusText),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<ArticleEditBloc>().add(SetArticleStatus(value));
        }
      },
    );
  }
}
