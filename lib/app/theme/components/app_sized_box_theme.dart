import 'package:conectasoc/app/theme/theme.dart';
import 'package:flutter/material.dart';

abstract class AppSizedBoxTheme {
  // Multiples del unit (2px)
  static const double xxxs = kSizedBoxUnit * 1; // 2
  static const double xxs = kSizedBoxUnit * 2; // 4
  static const double xs = kSizedBoxUnit * 4; // 8
  static const double ssm = kSizedBoxUnit * 6; // 12
  static const double sm = kSizedBoxUnit * 8; // 16
  static const double mmd = kSizedBoxUnit * 10; // 20
  static const double md = kSizedBoxUnit * 12; // 24
  static const double lg = kSizedBoxUnit * 16; // 32
  static const double xl = kSizedBoxUnit * 22; // 44
  static const double xxl = kSizedBoxUnit * 24; // 48

  // PADDINGS COMUNES
  static SizedBox get fieldVertical => SizedBox(height: xxxs);
  static SizedBox get fieldVerticalTinySeparator => SizedBox(height: xxs);
  static SizedBox get fieldVerticalSmallSeparator => SizedBox(height: xs);
  static SizedBox get fieldVerticalSsm => SizedBox(height: ssm);
  static SizedBox get fieldVerticalSeparator => SizedBox(height: sm);
  static SizedBox get fieldVerticalMmd => SizedBox(height: mmd);
  static SizedBox get fieldVerticalDoubleSeparator => SizedBox(height: md);
  static SizedBox get fieldVerticalLg => SizedBox(height: lg);
  static SizedBox get fieldVerticalXl => SizedBox(height: xl);
  static SizedBox get fieldVerticalLastSeparator => SizedBox(height: xxl);

  static SizedBox get fieldHorizontal => SizedBox(width: xxxs);
  static SizedBox get fieldHorizontalTinySeparator => SizedBox(width: xxs);
  static SizedBox get fieldHorizontalSmallSeparator => SizedBox(width: xs);
  static SizedBox get fieldHorizontalSsm => SizedBox(width: ssm);
  static SizedBox get fieldHorizontalSeparator => SizedBox(width: sm);
  static SizedBox get fieldHorizontalMmd => SizedBox(width: mmd);
  static SizedBox get fieldHorizontalDoubleSeparator => SizedBox(width: md);
  static SizedBox get fieldHorizontalLg => SizedBox(width: lg);
  static SizedBox get fieldHorizontalXl => SizedBox(width: xl);
  static SizedBox get fieldHorizontalXxl => SizedBox(width: xxl);
}
