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
            if (state is HomeLoaded) ...[
              Visibility(
                visible: state.showSearch,
                maintainState: true,
                child: SearchFieldWidget(
                  height: 40.0,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  fillColor: const Color.fromARGB(255, 233, 236, 231),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  borderRadius: 8.0,
                ),
              ),
              Visibility(
                visible: state.showFilter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: const CategoryFilterBarWidget(),
                ),
              ),
            ],
            // if (state is! HomeLoaded) ...[
            //   // Fallback for initial/loading states if needed
            //   SearchFieldWidget(
            //     height: 40.0,
            //     contentPadding: const EdgeInsets.symmetric(
            //       vertical: 12,
            //       horizontal: 20,
            //     ),
            //     fillColor: const Color.fromARGB(255, 221, 235, 212),
            //     textStyle: const TextStyle(
            //       fontSize: 16,
            //       fontWeight: FontWeight.w500,
            //       color: Colors.black87,
            //     ),
            //     borderRadius: 8.0,
            //   ),
            //   const CategoryFilterBarWidget(),
            // ],
            Expanded(
              child: ArticleListWidget(),
            ),
          ],
        );
      },
    );
  }
}
