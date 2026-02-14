import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/home/presentation/bloc/bloc.dart';
import 'package:conectasoc/l10n/app_localizations.dart';

class SearchFieldWidget extends StatefulWidget {
  final double? height;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final TextStyle? textStyle;
  final double? fontSize;
  final double? borderRadius;

  const SearchFieldWidget({
    super.key,
    this.height,
    this.contentPadding,
    this.fillColor,
    this.textStyle,
    this.fontSize,
    this.borderRadius,
  });

  @override
  State<SearchFieldWidget> createState() => _SearchFieldWidgetState();
}

class _SearchFieldWidgetState extends State<SearchFieldWidget> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      context.read<HomeBloc>().add(SearchQueryChanged(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeLoaded) {
          // Update controller only if text differs to avoid cursor jump
          if (_searchController.text != state.searchTerm) {
            _searchController.text = state.searchTerm;
            // Move cursor to end
            _searchController.selection = TextSelection.fromPosition(
              TextPosition(offset: _searchController.text.length),
            );
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
          left: 8.0,
          right: 8.0,
        ),
        child: SizedBox(
          height: widget.height,
          child: TextField(
            controller: _searchController,
            style: widget.textStyle ??
                (widget.fontSize != null
                    ? TextStyle(fontSize: widget.fontSize)
                    : null),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).search,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: widget.fillColor,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
      ),
    );
  }
}
