import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_error_helper.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_input_decoration.dart';
import '../widgets/primary_button.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({
    super.key,
    this.token,
    required this.onSubmit,
  });

  final String? token;
  final Future<void> Function(String token, String newPassword) onSubmit;

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _tokenCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.token != null) _tokenCtrl.text = widget.token!;
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    final token = _tokenCtrl.text.trim();
    if (token.isEmpty) {
      setState(() => _error = 'Ingresa el token que recibiste por correo');
      return;
    }
    final pwd = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;
    if (pwd.length < 8) {
      setState(() => _error = 'La contraseña debe tener al menos 8 caracteres');
      return;
    }
    if (pwd != confirm) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.onSubmit(token, pwd);
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
      title: 'Crear nueva contraseña',
      subtitle: 'Ingresa una nueva contraseña para cambiarla.',
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
          if (widget.token == null) ...[
            TextField(
              controller: _tokenCtrl,
              style: authInputTextStyle(),
              decoration: authInputDecoration(
                context,
                label: 'Token del correo',
                hint: 'Pega aquí el token del enlace',
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            style: authInputTextStyle(),
            decoration: authInputDecoration(
              context,
              label: 'Nueva contraseña',
              hint: 'Mín. 8 caracteres',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: MeEncontrastePalette.gray500,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmCtrl,
            obscureText: _obscureConfirm,
            style: authInputTextStyle(),
            decoration: authInputDecoration(
              context,
              label: 'Confirmar contraseña',
              hint: 'Repite la contraseña',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  color: MeEncontrastePalette.gray500,
                ),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: _loading ? 'Guardando...' : 'Cambiar contraseña',
            onPressed: _loading ? () {} : _submit,
          ),
        ],
      ),
    );
  }
}
