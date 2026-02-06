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
        style: TextStyle(
          fontSize: 10.0,
          color: Theme.of(context).primaryColor,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
