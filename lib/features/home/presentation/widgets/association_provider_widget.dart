// lib/features/home/presentation/widgets/association_provider.dart

import 'package:conectasoc/features/associations/domain/entities/entities.dart';
import 'package:conectasoc/features/associations/domain/usecases/usecases.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:conectasoc/injection_container.dart';

class AssociationProviderWidget extends StatefulWidget {
  final Widget child;

  const AssociationProviderWidget({super.key, required this.child});

  static List<AssociationEntity> of(BuildContext context) {
    final _AssociationProviderScope? scope =
        context.dependOnInheritedWidgetOfExactType<_AssociationProviderScope>();
    assert(scope != null, 'No AssociationProvider found in context');
    return scope!.associations;
  }

  @override
  State<AssociationProviderWidget> createState() =>
      _AssociationProviderWidgetState();
}

class _AssociationProviderWidgetState extends State<AssociationProviderWidget> {
  List<AssociationEntity> _associations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAssociations();
  }

  Future<void> _loadAssociations() async {
    final result = await sl<GetAllAssociationsUseCase>()();
    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });
        }
      },
      (associations) {
        if (mounted) {
          setState(() {
            _associations = associations;
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                l10n.errorLoadingAssociations(_error ?? ''),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadAssociations,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_associations.isEmpty) {
      return Center(
        child: Text(l10n.noArticlesYet),
      );
    }

    return _AssociationProviderScope(
      associations: _associations,
      child: widget.child,
    );
  }
}

class _AssociationProviderScope extends InheritedWidget {
  final List<AssociationEntity> associations;

  const _AssociationProviderScope({
    required this.associations,
    required super.child,
  });

  @override
  bool updateShouldNotify(_AssociationProviderScope oldWidget) =>
      associations != oldWidget.associations;
}
