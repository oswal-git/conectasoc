import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:conectasoc/features/associations/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/users/presentation/bloc/bloc.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:conectasoc/services/snackbar_service.dart';

class UserEditPage extends StatelessWidget {
  final String userId;

  const UserEditPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final isCreating = userId.isEmpty;
    return BlocProvider(
      create: (context) {
        final bloc = sl<UserEditBloc>();
        if (isCreating) {
          bloc.add(PrepareUserCreation());
        } else {
          bloc.add(LoadUserDetails(userId));
        }
        return bloc;
      },
      child: _UserEditView(isCreating: isCreating),
    );
  }
}

class _UserEditView extends StatefulWidget {
  final bool isCreating;
  const _UserEditView({required this.isCreating});

  @override
  State<_UserEditView> createState() => _UserEditViewState();
}

class _UserEditViewState extends State<_UserEditView> {
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateControllers(UserEntity user) {
    _nameController.text = user.firstName;
    _lastnameController.text = user.lastName;
    _emailController.text = user.email;
    _phoneController.text = user.phone ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCreating ? l10n.createUser : l10n.editUser),
      ),
      body:
          BlocConsumer<UserEditBloc, UserEditState>(listener: (context, state) {
        if (state is UserEditLoaded) {
          _updateControllers(state.user);
          if (state.errorMessage != null) {
            SnackBarService.showSnackBar(state.errorMessage!, isError: true);
          }
        } else if (state is UserEditSuccess) {
          SnackBarService.showSnackBar(l10n.changesSavedSuccessfully);
          Navigator.of(context).pop();
        } else if (state is UserEditFailure) {
          SnackBarService.showSnackBar(state.message, isError: true);
        }
      }, builder: (context, state) {
        if (state is UserEditLoading || state is UserEditInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is UserEditFailure) {
          return Center(child: Text(state.message));
        }
        if (state is UserEditLoaded) {
          final user = state.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                          ? CachedNetworkImageProvider(user.avatarUrl!)
                          : null,
                  child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                      ? Text(user.initials,
                          style: const TextStyle(fontSize: 40))
                      : null,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.name),
                  onChanged: (value) => context
                      .read<UserEditBloc>()
                      .add(UserFirstNameChanged(value)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastnameController,
                  decoration: InputDecoration(labelText: l10n.lastname),
                  onChanged: (value) => context
                      .read<UserEditBloc>()
                      .add(UserLastNameChanged(value)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: l10n.email),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) =>
                      context.read<UserEditBloc>().add(UserEmailChanged(value)),
                ),
                if (widget.isCreating) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    onChanged: (value) => context
                        .read<UserEditBloc>()
                        .add(UserPasswordChanged(value)),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: l10n.phone),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) =>
                      context.read<UserEditBloc>().add(UserPhoneChanged(value)),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: user.language,
                  decoration: InputDecoration(labelText: l10n.language),
                  items: [
                    DropdownMenuItem(
                        value: 'es', child: Text(l10n.langSpanish)),
                    DropdownMenuItem(
                        value: 'en', child: Text(l10n.langEnglish)),
                    DropdownMenuItem(
                        value: 'ca', child: Text(l10n.langCatalan)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      context
                          .read<UserEditBloc>()
                          .add(UserLanguageChanged(value));
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: user.notificationTime,
                  decoration: InputDecoration(labelText: l10n.notifications),
                  items: [
                    DropdownMenuItem(value: 0, child: Text(l10n.never)),
                    DropdownMenuItem(value: 1, child: Text(l10n.morning)),
                    DropdownMenuItem(value: 2, child: Text(l10n.afternoon)),
                    DropdownMenuItem(
                        value: 12, child: Text(l10n.morningAndAfternoon)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      context
                          .read<UserEditBloc>()
                          .add(UserNotificationTimeChanged(value));
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserStatus>(
                  initialValue: user.status,
                  decoration: InputDecoration(labelText: l10n.status),
                  items: UserStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      context
                          .read<UserEditBloc>()
                          .add(UserStatusChanged(value));
                    }
                  },
                ),
                const SizedBox(height: 32),
                _MembershipSection(
                  user: user,
                  allAssociations: state.allAssociations,
                ),
                const SizedBox(height: 16),
                if (!widget.isCreating)
                  TextButton.icon(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: Text(
                      l10n.deleteUser,
                      style: const TextStyle(color: Colors.red),
                    ),
                    onPressed: state.isSaving
                        ? null
                        : () => _showDeleteConfirmation(
                              context,
                              user.fullName,
                            ),
                  ),
                const SizedBox(height: 32),
                ElevatedButton(
                    onPressed: state.isSaving
                        ? null
                        : () =>
                            context.read<UserEditBloc>().add(SaveUserChanges()),
                    child: state.isSaving
                        ? const CircularProgressIndicator()
                        : Text(widget.isCreating
                            ? l10n.createUser
                            : l10n.saveChanges)),
                const SizedBox(height: 48), // Espacio extra al final
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String userName) {
    final l10n = AppLocalizations.of(context);
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteUser),
        content: Text(l10n.deleteUserConfirmation(userName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<UserEditBloc>().add(DeleteUser());
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _MembershipSection extends StatelessWidget {
  final UserEntity user;
  final List<AssociationEntity> allAssociations;

  const _MembershipSection({
    required this.user,
    required this.allAssociations,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentUser =
        (context.read<AuthBloc>().state as AuthAuthenticated).user;
    final userMemberships = user.memberships;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.memberships,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (userMemberships.isEmpty) Text(l10n.userHasNoMemberships),
        ...userMemberships.entries.map((entry) {
          final association = allAssociations.firstWhere(
            (assoc) => assoc.id == entry.key,
            orElse: () => AssociationEntity.empty()
                .copyWith(id: entry.key, shortName: 'Desconocida'),
          );
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(association.longName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: entry.value,
                          decoration:
                              InputDecoration(labelText: l10n.roleTitle),
                          items: {
                            // Lista base de roles
                            'admin',
                            'editor',
                            'member',
                            // Añadir 'superadmin' a la lista solo si el usuario actual es superadmin
                            // y el rol que se está editando ya es 'superadmin'.
                            if (currentUser.isSuperAdmin &&
                                entry.value == 'superadmin')
                              'superadmin',
                          }.toList().map((role) {
                            // toSet().toList() para evitar duplicados
                            return DropdownMenuItem(
                              value: role,
                              child: Text(l10n.role(role)),
                            ); // Usar l10n para traducir el rol
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              context
                                  .read<UserEditBloc>()
                                  .add(UserRoleChanged(entry.key, value));
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => context
                            .read<UserEditBloc>()
                            .add(RemoveMembership(entry.key)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: Text(l10n.addMembership),
            onPressed: () => _showAddMembershipDialog(context),
          ),
        ),
      ],
    );
  }

  void _showAddMembershipDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final availableAssociations = allAssociations
        .where((assoc) => !user.memberships.containsKey(assoc.id))
        .toList();

    String? selectedAssociationId;
    String selectedRole = 'member';

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.addMembershipDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                hint: Text(l10n.selectAssociation),
                items: availableAssociations.map((assoc) {
                  return DropdownMenuItem(
                    value: assoc.id,
                    child: Text(assoc.longName),
                  );
                }).toList(),
                onChanged: (value) => selectedAssociationId = value,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: InputDecoration(labelText: l10n.roleTitle),
                items: ['admin', 'editor', 'member'].map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) selectedRole = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () {
                if (selectedAssociationId != null) {
                  context
                      .read<UserEditBloc>()
                      .add(AddMembership(selectedAssociationId!, selectedRole));
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
  }
}
