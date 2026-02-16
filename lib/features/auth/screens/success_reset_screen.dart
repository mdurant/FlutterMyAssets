import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import '../widgets/primary_button.dart';

/// Pantalla de éxito tras cambiar la contraseña. Muestra icono, mensaje y botón Continuar → Login.
class SuccessResetScreen extends StatelessWidget {
  const SuccessResetScreen({
    super.key,
    required this.onContinue,
  });

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MeEncontrastePalette.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: MeEncontrastePalette.primary100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 56,
                  color: MeEncontrastePalette.primary600,
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.check_circle,
                size: 32,
                color: MeEncontrastePalette.primary600,
              ),
              const SizedBox(height: 24),
              Text(
                '¡Listo!',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: MeEncontrastePalette.gray900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tu contraseña ha sido cambiada. Inicia sesión de nuevo con tu nueva contraseña.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: MeEncontrastePalette.gray600,
                  height: 1.4,
                ),
              ),
              const Spacer(flex: 2),
              PrimaryButton(
                label: 'Continuar',
                onPressed: onContinue,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
