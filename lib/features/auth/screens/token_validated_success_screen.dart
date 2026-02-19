import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import '../widgets/primary_button.dart';

/// Pantalla de éxito cuando el usuario ha validado su token vía correo.
/// Layout: icono escudo con check, título "¡Éxito!", mensaje y botón Continuar → Login.
class TokenValidatedSuccessScreen extends StatelessWidget {
  const TokenValidatedSuccessScreen({
    super.key,
    required this.builderLogin,
  });

  final Widget Function() builderLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MeEncontrastePalette.gray50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              _buildSuccessIcon(),
              const SizedBox(height: 24),
              Text(
                '¡Éxito!',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: MeEncontrastePalette.gray900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tu token ha sido validado. Todo listo para ingresar con tus nuevas credenciales.',
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
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => builderLogin()),
                    (route) => route.isFirst,
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            MeEncontrastePalette.primary100,
            MeEncontrastePalette.primary50.withValues(alpha: 0.6),
            MeEncontrastePalette.primary50.withValues(alpha: 0),
          ],
          stops: const [0.4, 0.7, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            color: MeEncontrastePalette.primary600,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
