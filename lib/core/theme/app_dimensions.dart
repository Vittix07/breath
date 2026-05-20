import 'package:flutter/material.dart';

class AppDimensions {
  AppDimensions._();

  static const double cardRadius = 22;
  static const double buttonRadius = 16;
  static const double badgeRadius = 12;

  static const EdgeInsets cardPadding = EdgeInsets.all(20);
  static const double cardGap = 14;

  // Ombre calde e visibili (non grigio freddo)
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x12957860),   // ombra calda ambrata
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];
}
