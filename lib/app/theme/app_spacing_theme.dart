import 'package:conectasoc/app/theme/theme.dart';
import 'package:flutter/material.dart';

abstract class AppSpacingTheme {
  // Multiples del unit (4px)
  static const double xxs = kSpaceUnit * 1; // 4
  static const double xs = kSpaceUnit * 2; // 8
  static const double ssm = kSpaceUnit * 3; // 12
  static const double sm = kSpaceUnit * 4; // 16
  static const double mmd = kSpaceUnit * 5; // 20
  static const double md = kSpaceUnit * 6; // 24
  static const double lg = kSpaceUnit * 8; // 32

  // PADDINGS COMUNES
  static EdgeInsets get paddingList => EdgeInsets.all(xs);
  static EdgeInsets get paddingContainer => EdgeInsets.all(md);
  static EdgeInsets get paddingPage => EdgeInsets.all(md);
  static EdgeInsets get paddingCard => EdgeInsets.all(md);
  static EdgeInsets get paddingInput =>
      EdgeInsets.symmetric(horizontal: lg, vertical: sm);
  static EdgeInsets get paddingTextField =>
      EdgeInsets.symmetric(horizontal: sm);
  static EdgeInsets get paddingButton =>
      EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static EdgeInsets get paddingBox =>
      EdgeInsets.symmetric(horizontal: ssm, vertical: xs);

  // PADDINGS LIST
  static EdgeInsets get paddingList =>
      EdgeInsets.symmetric(horizontal: sm, vertical: xs);

  // PADDINGS VERTICALES
  static EdgeInsets get paddingSection => EdgeInsets.symmetric(vertical: xs);
  static EdgeInsets get paddingTopSection => EdgeInsets.only(top: xxs);
  static EdgeInsets get paddingCover => EdgeInsets.only(bottom: ssm);

  /// Padding search and filter widget
  static EdgeInsets get paddingSearchAndFilterWidget =>
      EdgeInsets.only(top: xxs, bottom: xxs, left: xs, right: xs);
  static EdgeInsets get paddingSearch =>
      EdgeInsets.only(top: ssm, bottom: ssm, left: mmd, right: mmd);
  static EdgeInsets get paddingFilter => EdgeInsets.only(top: xxs);

  // MARGINS
  static EdgeInsets get marginSection => EdgeInsets.only(top: lg);

  /// Stroke widths para progress, borders
  static const double strokeThin = kStrokeWidthThin; // 2px
  static const double strokeMedium = kStrokeWidthMedium; // 3px
  static const double strokeThick = kStrokeWidthThick; // 4px
}
