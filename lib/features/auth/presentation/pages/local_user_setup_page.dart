import 'package:conectasoc/core/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../domain/entities/association_entity.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../injection_container.dart';

class LocalUserSetupPage extends StatefulWidget {
  const LocalUserSetupPage({super.key});

  @override
  State<LocalUserSetupPage> createState() => _LocalUserSetupPageState();
}

class _LocalUserSetupPageState extends State<LocalUserSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String? _selectedAssociationId;
  List<AssociationEntity> _associations = [];
  bool _isLoadingAssociations = true;

  @override
  void initState() {
    super.initState();
    _loadAssociations();
  }

  Future<void> _loadAssociations() async {
    try {
      final repository = getIt<AuthRepository>();
      final associations = await repository.getAllAssociations();

      setState(() {
        _associations = associations;
        _isLoadingAssociations = false;
        if (_associations.isNotEmpty) {
          _selectedAssociationId = _associations.first.id;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingAssociations = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando asociaciones: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (_selectedAssociationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona una asociación')),
        );
        return;
      }

      context.read<AuthBloc>().add(
            AuthSaveLocalUser(
              displayName: _nameController.text.trim(),
              associationId: _selectedAssociationId!,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Lectura'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLocalUser) {
            // Navegar a home
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/',
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icono
                Icon(
                  Icons.visibility,
                  size: 80,
                  color: Colors.blue[300],
                ),

                const SizedBox(height: 24),

                // Título
                const Text(
                  'Modo Solo Lectura',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Descripción
                Text(
                  'Explora contenido sin registro. Solo necesitamos tu nombre y la asociación que deseas seguir.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Campo de nombre
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Tu nombre',
                    hintText: 'Ej: Juan Pérez',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) => Validators.validateName(value),
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 16),

                // Selector de asociación
                if (_isLoadingAssociations)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_associations.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(height: 8),
                        Text(
                          'No hay asociaciones disponibles aún',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Debes crear una cuenta completa para registrar la primera asociación',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: _selectedAssociationId,
                    decoration: InputDecoration(
                      labelText: 'Asociación',
                      prefixIcon: const Icon(Icons.business),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _associations.map((association) {
                      return DropdownMenuItem<String>(
                        value: association.id,
                        child: Text(association.shortName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAssociationId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Selecciona una asociación';
                      }
                      return null;
                    },
                  ),

                const SizedBox(height: 24),

                // Info box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Solo podrás ver contenido. Para crear contenido y recibir notificaciones, necesitas una cuenta completa.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Botón continuar
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;

                    return ElevatedButton(
                      onPressed: _associations.isEmpty || isLoading
                          ? null
                          : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Continuar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Link para crear cuenta completa
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO: Navegar a registro
                  },
                  child: const Text('¿Prefieres crear una cuenta completa?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
