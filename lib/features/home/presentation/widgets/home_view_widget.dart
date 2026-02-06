import 'dart:async';
import 'package:conectasoc/features/home/presentation/widgets/article_list_widget.dart';
import 'package:conectasoc/features/home/presentation/widgets/category_filter_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:conectasoc/features/home/presentation/bloc/bloc.dart';
import 'package:conectasoc/l10n/app_localizations.dart';

class HomeViewWidget extends StatefulWidget {
  const HomeViewWidget({super.key});
  @override
  State<HomeViewWidget> createState() => HomeViewWidgetState();
}

class HomeViewWidgetState extends State<HomeViewWidget> {
  // Debounce timer for search input
  static Timer? _searchDebounce;

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
            Padding(
              padding: const EdgeInsets.only(
                  top: 4.0, bottom: 0.0, left: 8.0, right: 8.0),
              child: TextField(
                controller: TextEditingController(
                    text: (context.watch<HomeBloc>().state is HomeLoaded)
                        ? (context.watch<HomeBloc>().state as HomeLoaded)
                            .searchTerm
                        : ''),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).search,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                onChanged: (query) {
                  _searchDebounce?.cancel();
                  _searchDebounce =
                      Timer(const Duration(milliseconds: 300), () {
                    context.read<HomeBloc>().add(SearchQueryChanged(query));
                  });
                },
              ),
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
