import 'package:flutter/material.dart';

/// Classe singleton contenant les constantes et configuration de l'application.
abstract class Constants {
  // Animation
  static const Duration animationTransitionDuration =
      Duration(milliseconds: 500);
  static const Duration animationDurationShort = Duration(milliseconds: 150);
  static const Curve animationTransitionCurve = Curves.ease;

  static const fieldPhoneMaxLength = 14;
  static const fieldMailMaxLength = 256;

  static const loadingSpinnerSize = 40.0;
}
