import 'package:conectasoc/features/home/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:conectasoc/features/home/presentation/bloc/bloc.dart';

class HomeViewWidget extends StatefulWidget {
  const HomeViewWidget({super.key});
  @override
  State<HomeViewWidget> createState() => HomeViewWidgetState();
}

class HomeViewWidgetState extends State<HomeViewWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final bool isLoading = (state is HomeLoaded) && state.isLoading;

        return Column(
          children: [
            // Show a loading indicator when toggling edit mode or loading more
            if (isLoading)
              const LinearProgressIndicator(
                minHeight: 2,
              ),
            SearchFieldWidget(
              height: 40.0, // Altura total del campo
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12, // Padding vertical interior
                horizontal: 20, // Padding horizontal interior
              ),
              fillColor:
                  const Color.fromARGB(255, 221, 235, 212), // Color de fondo
              textStyle: TextStyle(
                // O estilo completo de texto
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              borderRadius: 8.0, // Radio de borde
            ),
            const CategoryFilterBarWidget(),
            Expanded(
              child: ArticleListWidget(),
            ),
          ],
        );
      },
    );
  }
}
