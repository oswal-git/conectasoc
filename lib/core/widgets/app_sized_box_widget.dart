import 'package:flutter/material.dart';

class SizedBoxWidget extends StatelessWidget {
  final double spaceBoxImageWidth = 56;
  final double spaceBoxImageHeigjt = 72;
  final Widget child;
  final double? width;
  final double? height;

  const SizedBoxWidget({
    super.key,
    required this.child,
    this.width,
    this.height,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width ?? spaceBoxImageWidth,
        height: height ?? spaceBoxImageHeigjt,
        child: child);
  }
}

class SizedBoxWidgetHeight extends StatelessWidget {
  final double spaceBoxImageWidth = 56;
  final double spaceBoxImageHeigjt = 72;
  final Widget child;
  final double? width;
  final double? height;

  const SizedBoxWidgetHeight(
      {super.key, required this.child, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width ?? spaceBoxImageWidth,
        height: height ?? spaceBoxImageHeigjt,
        child: child);
  }
}
