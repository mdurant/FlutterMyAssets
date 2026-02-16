import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/me_encontraste_palette.dart';

/// Estilo del texto que escribe el usuario en los campos (color oscuro para buena legibilidad).
TextStyle authInputTextStyle() {
  return GoogleFonts.outfit(
    color: MeEncontrastePalette.dark,
    fontSize: 16,
  );
}

InputDecoration authInputDecoration(
  BuildContext context, {
  required String label,
  String? hint,
  Widget? suffixIcon,
  bool error = false,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: MeEncontrastePalette.gray50,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: error ? MeEncontrastePalette.error500 : MeEncontrastePalette.gray300,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: MeEncontrastePalette.primary600, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: MeEncontrastePalette.error500),
    ),
    labelStyle: GoogleFonts.outfit(color: MeEncontrastePalette.gray600),
  );
}
