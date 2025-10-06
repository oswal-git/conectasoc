import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/users/domain/entities/entities.dart';
import 'package:conectasoc/features/users/presentation/bloc/bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    // Pasamos el AuthBloc del contexto al evento
    context.read<ProfileBloc>().add(LoadUserProfile(context.read<AuthBloc>()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded && state.isSaving) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                );
              }
              return IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    context
                        .read<ProfileBloc>()
                        .add(SaveProfileChanges(context.read<AuthBloc>()));
                  }
                },
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          } else if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Perfil guardado con éxito'),
                  backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            return _buildProfileForm(state.user);
          } else {
            return const Center(child: Text('Error al cargar el perfil.'));
          }
        },
      ),
    );
  }

  Widget _buildProfileForm(ProfileEntity user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildProfileImage(user.photoUrl),
          const SizedBox(height: 24),
          FormBuilder(
            key: _formKey,
            initialValue: {
              'name': user.name,
              'lastname': user.lastname,
              'email': user.email,
              'phone': user.phone,
              'language': user.language,
            },
            child: Column(
              children: [
                FormBuilderTextField(
                  name: 'name',
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: FormBuilderValidators.required(),
                  onChanged: (value) => context
                      .read<ProfileBloc>()
                      .add(ProfileNameChanged(value ?? '')),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'lastname',
                  decoration: const InputDecoration(labelText: 'Apellidos'),
                  validator: FormBuilderValidators.required(),
                  onChanged: (value) => context
                      .read<ProfileBloc>()
                      .add(ProfileLastnameChanged(value ?? '')),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'email',
                  decoration: const InputDecoration(labelText: 'Email'),
                  enabled: false,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'phone',
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  onChanged: (value) => context
                      .read<ProfileBloc>()
                      .add(ProfilePhoneChanged(value ?? '')),
                ),
                const SizedBox(height: 16),
                FormBuilderDropdown<String>(
                  name: 'language',
                  decoration: const InputDecoration(labelText: 'Idioma'),
                  items: const [
                    DropdownMenuItem(value: 'es', child: Text('Español')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ca', child: Text('Català')),
                  ],
                  onChanged: (value) => context
                      .read<ProfileBloc>()
                      .add(ProfileLanguageChanged(value ?? 'es')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String? imageUrl) {
    ImageProvider? backgroundImage;
    if (_localImagePath != null) {
      backgroundImage = FileImage(File(_localImagePath!));
    } else if (imageUrl != null) {
      backgroundImage = CachedNetworkImageProvider(imageUrl);
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: backgroundImage,
            child: backgroundImage == null
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).primaryColor,
              child: IconButton(
                icon:
                    const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                onPressed: _showImageSourceActionSheet,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Cámara'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      _cropImage(pickedFile.path);
    }
  }

  Future<void> _cropImage(String filePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: filePath,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Recortar Imagen',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]),
        IOSUiSettings(
          title: 'Recortar Imagen',
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
        ),
      ],
    );

    if (croppedFile != null) {
      // Verificar si el widget sigue montado antes de usar el context.
      if (!mounted) return;

      setState(() {
        _localImagePath = croppedFile.path;
      });
      context.read<ProfileBloc>().add(ProfileImageChanged(croppedFile.path));
    }
  }
}
