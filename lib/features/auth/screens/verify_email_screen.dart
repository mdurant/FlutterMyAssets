import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_error_helper.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_input_decoration.dart';
import '../widgets/primary_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    super.key,
    this.email,
    required this.onVerify,
    required this.onResend,
  });

  final String? email;
  /// Al verificar, se pasa el token y el email (para el flujo OTP posterior).
  final Future<void> Function(String token, String email) onVerify;
  final Future<void> Function()? onResend;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _tokenCtrl = TextEditingController();
  bool _loading = false;
  bool _resending = false;
  String? _error;
  String? _resendMessage;

  @override
  void dispose() {
    _tokenCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleResend() async {
    if (widget.onResend == null) return;
    setState(() {
      _error = null;
      _resendMessage = null;
      _resending = true;
    });
    try {
      await widget.onResend!();
      if (mounted) setState(() {
        _resending = false;
        _resendMessage = 'Correo reenviado. Revisa tu bandeja (y spam).';
      });
    } catch (e) {
      if (mounted) setState(() {
        _resending = false;
        _error = apiErrorMessage(e);
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    final token = _tokenCtrl.text.trim();
    if (token.isEmpty) {
      setState(() => _error = 'Ingresa el código que recibiste por correo');
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.onVerify(token, widget.email ?? '');
      if (!mounted) return;
      setState(() => _error = null);
    } catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Verificar correo',
      subtitle: widget.email != null
          ? 'Ingresa el código que enviamos a ${widget.email}'
          : 'Ingresa el código que enviamos a tu correo.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_resendMessage != null) ...[
            Text(
              _resendMessage!,
              style: GoogleFonts.outfit(color: MeEncontrastePalette.primary600, fontSize: 13),
            ),
            const SizedBox(height: 12),
          ],
          if (_error != null) ...[
            Text(
              _error!,
              style: GoogleFonts.outfit(color: MeEncontrastePalette.error500, fontSize: 14),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _tokenCtrl,
            style: authInputTextStyle(),
            decoration: authInputDecoration(
              context,
              label: 'Código de verificación',
              hint: 'Pega aquí el token del correo',
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: _loading ? 'Verificando...' : 'Verificar',
            onPressed: _loading ? () {} : _submit,
          ),
          if (widget.onResend != null) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: _resending ? null : _handleResend,
                icon: Icon(
                  Icons.refresh,
                  size: 18,
                  color: _resending ? MeEncontrastePalette.gray500 : MeEncontrastePalette.primary600,
                ),
                label: Text(
                  _resending ? 'Reenviando...' : 'Reenviar código',
                  style: GoogleFonts.outfit(
                    color: _resending ? MeEncontrastePalette.gray500 : MeEncontrastePalette.primary600,
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
