import 'package:conectasoc/features/associations/presentation/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/services/snackbar_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SettingsBloc>()..add(LoadSettingsData()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Configuración')),
        body: BlocConsumer<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state is SettingsError) {
              SnackBarService.showSnackBar(state.message, isError: true);
              // Reload data to potentially clear the error state
              context.read<SettingsBloc>().add(LoadSettingsData());
            }
          },
          builder: (context, state) {
            if (state is SettingsLoading || state is SettingsInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SettingsLoaded) {
              return _buildSettingsList(context, state);
            }
            return const Center(child: Text('Error inesperado'));
          },
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, SettingsLoaded state) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Categorías',
                style: Theme.of(context).textTheme.headlineSmall),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () => _showAddDialog(context, isCategory: true),
            ),
          ],
        ),
        const Divider(),
        ...state.categories.map((category) =>
            _buildCategoryTile(context, category, state.subcategoriesMap)),
      ],
    );
  }

  Widget _buildCategoryTile(BuildContext context, CategoryEntity category,
      Map<String, List<SubcategoryEntity>> subcategoriesMap) {
    final subcategories = subcategoriesMap[category.id] ?? [];
    return ExpansionTile(
      title: Text(category.name),
      leading: const Icon(Icons.category),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () =>
                _showEditDialog(context, category.id, category.name, true),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: () =>
                context.read<SettingsBloc>().add(DeleteCategory(category.id)),
          ),
          const Icon(Icons.expand_more), // Default expansion icon
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          child: Column(
            children: [
              ...subcategories.map((sub) => ListTile(
                    title: Text(sub.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () =>
                              _showEditDialog(context, sub.id, sub.name, false),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red, size: 18),
                          onPressed: () => context
                              .read<SettingsBloc>()
                              .add(DeleteSubcategory(sub.id)),
                        ),
                      ],
                    ),
                  )),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir Subcategoría'),
                  onPressed: () => _showAddDialog(context,
                      isCategory: false, categoryId: category.id),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showAddDialog(BuildContext context,
      {required bool isCategory, String? categoryId}) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final title = isCategory ? 'Nueva Categoría' : 'Nueva Subcategoría';

    return showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) =>
                  value!.isEmpty ? 'El nombre no puede estar vacío' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final name = controller.text;
                  if (isCategory) {
                    context.read<SettingsBloc>().add(AddCategory(name));
                  } else {
                    context
                        .read<SettingsBloc>()
                        .add(AddSubcategory(name, categoryId!));
                  }
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(
      BuildContext context, String id, String currentName, bool isCategory) {
    final controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();
    final title = isCategory ? 'Editar Categoría' : 'Editar Subcategoría';

    return showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Nuevo nombre'),
              validator: (value) =>
                  value!.isEmpty ? 'El nombre no puede estar vacío' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newName = controller.text;
                  if (isCategory) {
                    context
                        .read<SettingsBloc>()
                        .add(UpdateCategory(id, newName));
                  } else {
                    context
                        .read<SettingsBloc>()
                        .add(UpdateSubcategory(id, newName));
                  }
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
