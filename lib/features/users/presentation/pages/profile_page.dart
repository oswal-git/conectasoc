import 'dart:typed_data';

import 'package:conectasoc/core/services/image_picker_service.dart';
import 'package:conectasoc/features/users/domain/entities/entities.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/users/presentation/bloc/bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    // Pasamos el AuthBloc del contexto al evento
    context.read<ProfileBloc>().add(LoadUserProfile(context.read<AuthBloc>()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateFailure) {
          final message = state.error == 'NO_CHANGES_ERROR'
              ? l10n.noChangesToSave
              : state.error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        } else if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(l10n.profileSavedSuccess),
              backgroundColor: Colors.green));
        }
      },
      builder: (context, state) {
        final hasChanges = state is ProfileLoaded && state.hasChanges;

        return PopScope(
          canPop: !hasChanges,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final l10n = AppLocalizations.of(context);
            final discard = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.unsavedChangesTitle),
                    content: Text(l10n.unsavedChangesMessage),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l10n.stay),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(l10n.discard),
                      ),
                    ],
                  ),
                ) ??
                false;

            if (discard && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(l10n.editProfile),
              actions: [
                if (state is ProfileLoaded && state.isSaving)
                  const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Center(
                        child: CircularProgressIndicator(color: Colors.white)),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        context
                            .read<ProfileBloc>()
                            .add(SaveProfileChanges(context.read<AuthBloc>()));
                      }
                    },
                  ),
              ],
            ),
            body: _buildBody(state, l10n),
          ),
        );
      },
    );
  }

  Widget _buildBody(ProfileState state, AppLocalizations l10n) {
    if (state is ProfileLoading || state is ProfileInitial) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ProfileLoaded) {
      return _buildProfileForm(state, l10n);
    } else if (state is ProfileUpdateFailure) {
      return Center(child: Text(state.error));
    }
    return const SizedBox.shrink();
  }

  Widget _buildProfileForm(ProfileLoaded state, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildProfileImage(state.user.photoUrl, state.localImageBytes),
          const SizedBox(height: 8),
          Builder(builder: (context) {
            final authState = context.watch<AuthBloc>().state;
            String roleText = '';
            if (authState is AuthAuthenticated) {
              if (authState.user.isSuperAdmin) {
                roleText = 'SuperAdmin';
              } else {
                final role = authState.currentMembership?.role ?? 'asociado';
                // Usamos la traducción del rol si está disponible, si no, capitalizamos el rol técnico
                roleText = l10n.role(role == 'member' ? 'asociado' : role);
              }
            }
            return Text(
              roleText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
            );
          }),
          const SizedBox(height: 16),
          FormBuilder(
            key: _formKey,
            initialValue: {
              'name': state.user.name,
              'lastname': state.user.lastname,
              'email': state.user.email,
              'phone': state.user.phone,
              'language': state.user.language,
              'notificationTime1': state.user.notificationTime1,
              'notificationTime2': state.user.notificationTime2,
              'notificationTime3': state.user.notificationTime3,
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
                  readOnly: true,
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
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
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
                const SizedBox(height: 16),
                _buildNotificationSelectors(context, state.user, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSelectors(
      BuildContext context, ProfileEntity user, AppLocalizations l10n) {
    // Generar la lista de opciones cada 30 min (00:00, 00:30... 23:30)
    final List<DropdownMenuItem<String>> timeOptions = [
      const DropdownMenuItem(value: '', child: Text('---')),
    ];
    for (int hour = 0; hour < 24; hour++) {
      for (int min = 0; min < 60; min += 30) {
        final hourStr = hour.toString().padLeft(2, '0');
        final minStr = min.toString().padLeft(2, '0');
        final timeStr = '$hourStr:$minStr';
        timeOptions.add(DropdownMenuItem(
          value: timeStr,
          child: Text(timeStr),
        ));
      }
    }

    final hasTime1 =
        user.notificationTime1 != null && user.notificationTime1!.isNotEmpty;
    final hasTime2 =
        user.notificationTime2 != null && user.notificationTime2!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.notifications,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),

        // Hora 1
        Row(
          children: [
            Expanded(
              child: FormBuilderDropdown<String>(
                name: 'notificationTime1',
                decoration: const InputDecoration(labelText: 'Hora 1'),
                items: timeOptions,
                onChanged: (value) {
                  context
                      .read<ProfileBloc>()
                      .add(ProfileNotificationTime1Changed(value));
                  if (value == null || value.isEmpty) {
                    // Si se vacía hora 1, vaciar 2 y 3 para mantener consistencia
                    _formKey.currentState?.fields['notificationTime2']
                        ?.didChange(null);
                    _formKey.currentState?.fields['notificationTime3']
                        ?.didChange(null);
                    context
                        .read<ProfileBloc>()
                        .add(const ProfileNotificationTime2Changed(null));
                    context
                        .read<ProfileBloc>()
                        .add(const ProfileNotificationTime3Changed(null));
                  }
                },
              ),
            ),
            if (hasTime1)
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _formKey.currentState?.fields['notificationTime1']
                      ?.didChange('');
                  _formKey.currentState?.fields['notificationTime2']
                      ?.didChange('');
                  _formKey.currentState?.fields['notificationTime3']
                      ?.didChange('');
                  context
                      .read<ProfileBloc>()
                      .add(const ProfileNotificationTime1Changed(''));
                  context
                      .read<ProfileBloc>()
                      .add(const ProfileNotificationTime2Changed(''));
                  context
                      .read<ProfileBloc>()
                      .add(const ProfileNotificationTime3Changed(''));
                },
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Hora 2
        Row(
          children: [
            Expanded(
              child: FormBuilderDropdown<String>(
                name: 'notificationTime2',
                enabled: hasTime1,
                decoration: InputDecoration(
                  labelText: 'Hora 2',
                ),
                items: timeOptions,
                onChanged: (value) {
                  context
                      .read<ProfileBloc>()
                      .add(ProfileNotificationTime2Changed(value));
                  if (value == null || value.isEmpty) {
                    // Si se vacía hora 2, vaciar 3
                    _formKey.currentState?.fields['notificationTime3']
                        ?.didChange(null);
                    context
                        .read<ProfileBloc>()
                        .add(const ProfileNotificationTime3Changed(null));
                  }
                },
              ),
            ),
            if (hasTime2 && hasTime1)
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _formKey.currentState?.fields['notificationTime2']
                      ?.didChange('');
                  _formKey.currentState?.fields['notificationTime3']
                      ?.didChange('');
                  context
                      .read<ProfileBloc>()
                      .add(const ProfileNotificationTime2Changed(''));
                  context
                      .read<ProfileBloc>()
                      .add(const ProfileNotificationTime3Changed(''));
                },
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Hora 3
        Row(
          children: [
            Expanded(
              child: FormBuilderDropdown<String>(
                name: 'notificationTime3',
                enabled: hasTime2,
                decoration: InputDecoration(
                  labelText: 'Hora 3',
                ),
                items: timeOptions,
                onChanged: (value) => context
                    .read<ProfileBloc>()
                    .add(ProfileNotificationTime3Changed(value)),
              ),
            ),
            if (user.notificationTime3 != null &&
                user.notificationTime3!.isNotEmpty &&
                hasTime2)
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _formKey.currentState?.fields['notificationTime3']
                      ?.didChange('');
                  context
                      .read<ProfileBloc>()
                      .add(const ProfileNotificationTime3Changed(''));
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileImage(String? imageUrl, Uint8List? localImageBytes) {
    ImageProvider? backgroundImage;
    if (localImageBytes != null) {
      backgroundImage = MemoryImage(localImageBytes);
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
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
    final imageBytes = await ImagePickerService().pickImage(context);
    if (!mounted) return;
    if (imageBytes != null) {
      // El BLoC ahora recibe el File directamente
      context.read<ProfileBloc>().add(ProfileImageChanged(imageBytes));
    }
  }
}
