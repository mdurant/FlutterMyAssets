import 'package:flutter/material.dart';

/// Paleta "Me encontraste" — arriendo con confianza y rating de riesgo.
/// Primary (púrpura), Gray y Base según guía de color.
abstract class MeEncontrastePalette {
  // Base
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color dark = Color(0xFF061327);

  // Primary (púrpura) — botones, acentos, logo
  static const Color primary25 = Color(0xFFFCFAFF);
  static const Color primary50 = Color(0xFFF9F5FF);
  static const Color primary100 = Color(0xFFF4EBFF);
  static const Color primary200 = Color(0xFFE9D7FE);
  static const Color primary300 = Color(0xFFD6BBFB);
  static const Color primary400 = Color(0xFFB692F6);
  static const Color primary500 = Color(0xFF9E77ED);
  static const Color primary600 = Color(0xFF7F56D9);
  static const Color primary700 = Color(0xFF6941C6);
  static const Color primary800 = Color(0xFF533896);
  static const Color primary900 = Color(0xFF42307D);

  // Gray — fondos, texto secundario, bordes
  static const Color gray25 = Color(0xFFFCFCFC);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF2F4F7);
  static const Color gray200 = Color(0xFFEAECFD);
  static const Color gray300 = Color(0xFFD0D5DD);
  static const Color gray400 = Color(0xFF98A2B3);
  static const Color gray500 = Color(0xFF667085);
  static const Color gray600 = Color(0xFF475467);
  static const Color gray700 = Color(0xFF344054);
  static const Color gray800 = Color(0xFF1D2939);
  static const Color gray900 = Color(0xFF101828);

  // Error — mensajes y bordes de error
  static const Color error500 = Color(0xFFF04438);
}
