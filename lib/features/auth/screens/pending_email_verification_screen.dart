import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/primary_button.dart';
import 'token_validated_success_screen.dart';

/// Tras el registro: el usuario debe activar su cuenta solo desde el correo (enlace).
/// No se ingresa ningún token en la app. Al pulsar Continuar se muestra la pantalla de éxito.
class PendingEmailVerificationScreen extends StatelessWidget {
  const PendingEmailVerificationScreen({
    super.key,
    this.email,
    required this.builderLogin,
    this.onResend,
  });

  final String? email;
  /// Construye la pantalla de login a la que navegar tras "Token validado" → Continuar.
  final Widget Function() builderLogin;
  final Future<void> Function()? onResend;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Revisa tu correo',
      subtitle: email != null && email!.isNotEmpty
          ? 'Te enviamos un correo a $email con un enlace para activar tu cuenta.'
          : 'Te enviamos un correo con un enlace para activar tu cuenta.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'La activación se realiza solo desde el correo: haz clic en el enlace que enviamos. '
            'Cuando hayas activado tu cuenta, pulsa el botón de abajo.',
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: MeEncontrastePalette.gray600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Ya activé mi cuenta, continuar',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => TokenValidatedSuccessScreen(
                    builderLogin: builderLogin,
                  ),
                ),
              );
            },
          ),
          if (onResend != null) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () => onResend!(),
                icon: const Icon(Icons.refresh, size: 18, color: MeEncontrastePalette.primary600),
                label: Text(
                  'Reenviar correo',
                  style: GoogleFonts.outfit(
                    color: MeEncontrastePalette.primary600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
