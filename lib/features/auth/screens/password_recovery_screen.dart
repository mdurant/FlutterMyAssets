import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_error_helper.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_input_decoration.dart';
import '../widgets/primary_button.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({
    super.key,
    required this.onSubmit,
    required this.onBackToLogin,
    this.onGoToReset,
  });

  final Future<void> Function(String email) onSubmit;
  final VoidCallback onBackToLogin;
  final VoidCallback? onGoToReset;

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Ingresa un correo válido');
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.onSubmit(email);
      if (!mounted) return;
      setState(() => _sent = true);
    } catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: '¿Olvidaste tu contraseña?',
      subtitle: _sent
          ? 'Revisa tu correo y usa el enlace para restablecer tu contraseña.'
          : 'Selecciona cómo quieres restablecer tu contraseña. Te enviaremos un enlace por correo.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error != null) ...[
            Text(
              _error!,
              style: GoogleFonts.outfit(color: MeEncontrastePalette.error500, fontSize: 14),
            ),
            const SizedBox(height: 16),
          ],
          if (!_sent) ...[
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: authInputTextStyle(),
              decoration: authInputDecoration(
                context,
                label: 'Correo',
                hint: 'tu@correo.com',
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: _loading ? 'Enviando...' : 'Continuar',
              onPressed: _loading ? () {} : _submit,
            ),
          ] else if (widget.onGoToReset != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onGoToReset,
                style: OutlinedButton.styleFrom(
                  foregroundColor: MeEncontrastePalette.primary600,
                  side: const BorderSide(color: MeEncontrastePalette.primary600),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Ya tengo el token, cambiar contraseña',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: widget.onBackToLogin,
              child: Text(
                'Volver a iniciar sesión',
                style: GoogleFonts.outfit(color: MeEncontrastePalette.primary600, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
