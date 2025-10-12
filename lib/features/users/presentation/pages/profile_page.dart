import 'dart:io';

import 'package:conectasoc/core/services/image_picker_service.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile),
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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l10n.profileSavedSuccess),
                backgroundColor: Colors.green));
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            return _buildProfileForm(state.user, l10n);
          } else {
            return Center(child: Text(l10n.profileLoadError));
          }
        },
      ),
    );
  }

  Widget _buildProfileForm(ProfileEntity user, AppLocalizations l10n) {
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
                  decoration: InputDecoration(labelText: l10n.name),
                  validator: FormBuilderValidators.required(),
                  onChanged: (value) => context
                      .read<ProfileBloc>()
                      .add(ProfileNameChanged(value ?? '')),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'lastname',
                  decoration: InputDecoration(labelText: l10n.lastname),
                  validator: FormBuilderValidators.required(),
                  onChanged: (value) => context
                      .read<ProfileBloc>()
                      .add(ProfileLastnameChanged(value ?? '')),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'email',
                  decoration: InputDecoration(labelText: l10n.email),
                  enabled: false,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'phone',
                  decoration: InputDecoration(labelText: l10n.phone),
                  onChanged: (value) => context
                      .read<ProfileBloc>()
                      .add(ProfilePhoneChanged(value ?? '')),
                ),
                const SizedBox(height: 16),
                FormBuilderDropdown<String>(
                  name: 'language',
                  decoration: InputDecoration(labelText: l10n.language),
                  items: [
                    DropdownMenuItem(
                        value: 'es', child: Text(l10n.langSpanish)),
                    DropdownMenuItem(
                        value: 'en', child: Text(l10n.langEnglish)),
                    DropdownMenuItem(
                        value: 'ca', child: Text(l10n.langCatalan)),
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
                onPressed: () => _pickAndCropImage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndCropImage() async {
    final imagePath = await ImagePickerService().pickImage(context);
    if (imagePath != null) {
      if (!mounted) return;
      setState(() {
        _localImagePath = imagePath;
      });
      context.read<ProfileBloc>().add(ProfileImageChanged(imagePath));
    }
  }
}
