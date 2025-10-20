// lib/features/auth/presentation/pages/register_page.dart

import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/auth/presentation/widgets/register_form_widget.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // We provide a new RegisterBloc to this page, responsible for loading its own data.
    return BlocProvider(
      create: (context) => sl<RegisterBloc>()..add(LoadRegisterData()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.createAccount),
          elevation: 0,
        ),
        body: const RegisterView(),
      ),
    );
  }
}

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        if (state is RegisterLoading || state is RegisterInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is RegisterError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<RegisterBloc>().add(LoadRegisterData()),
                  child: Text(l10n.retry),
                )
              ],
            ),
          );
        }

        if (state is RegisterDataLoaded) {
          return SafeArea(
              child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  // The AuthBloc is still available in the context for form submission.
                  child: RegisterFormWidget(
                    associations: state.associations,
                    isFirstUser: state.isFirstUser,
                  ),
                ),
              ],
            ),
          ));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
