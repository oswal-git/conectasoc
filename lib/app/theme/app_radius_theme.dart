import 'package:conectasoc/app/theme/theme.dart';
import 'package:flutter/material.dart';

abstract class AppRadiusTheme {
  static const double xxs = kRadiusUnit * 1; // 4
  static const double xs = kRadiusUnit * 2; // 8
  static const double ssm = kRadiusUnit * 3; // 12
  static const double sm = kRadiusUnit * 4; // 16
  static const double xxxl = kRadiusUnit * 15; // 60

  static const double avatarRadius = xxxl;

  static Radius get clipRadius => Radius.circular(ssm);

  static BorderRadius get container => BorderRadius.circular(ssm);
  static BorderRadius get clip => BorderRadius.circular(ssm);
  static BorderRadius get button => BorderRadius.circular(ssm);
  static BorderRadius get card => BorderRadius.circular(sm);
  static BorderRadius get input => BorderRadius.circular(ssm);
}
