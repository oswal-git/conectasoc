import 'package:conectasoc/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ClickableCategoryWidget extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const ClickableCategoryWidget(
      {super.key, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        name,
        style: AppTheme.articleCategory(context)
            .copyWith(decoration: TextDecoration.underline),
      ),
    );
  }
}
