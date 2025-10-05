// lib/features/home/presentation/widgets/association_provider.dart

import 'package:flutter/material.dart';
import 'package:conectasoc/features/auth/domain/domain.dart';
import 'package:conectasoc/injection_container.dart';

class AssociationProvider extends StatefulWidget {
  final Widget child;

  const AssociationProvider({super.key, required this.child});

  static List<AssociationEntity> of(BuildContext context) {
    final _AssociationProviderScope? scope =
        context.dependOnInheritedWidgetOfExactType<_AssociationProviderScope>();
    assert(scope != null, 'No AssociationProvider found in context');
    return scope!.associations;
  }

  @override
  State<AssociationProvider> createState() => _AssociationProviderState();
}

class _AssociationProviderState extends State<AssociationProvider> {
  List<AssociationEntity> _associations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssociations();
  }

  Future<void> _loadAssociations() async {
    final result = await sl<GetAssociationsUseCase>()();
    result.fold(
      (failure) {
        // Handle error, maybe show a snackbar
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
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _AssociationProviderScope(
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
