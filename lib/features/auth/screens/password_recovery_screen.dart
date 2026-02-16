import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_error_helper.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/gradient_button.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: widget.onBackToLogin,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recuperar contraseña',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _sent
                    ? 'Revisa tu correo y usa el enlace para restablecer tu contraseña.'
                    : 'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
                style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                const SizedBox(height: 16),
              ],
              if (!_sent) ...[
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    hintText: 'tu@correo.com',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: _loading ? 'Enviando...' : 'Enviar enlace',
                    onPressed: _loading ? () {} : _submit,
                  ),
                ),
              ] else if (widget.onGoToReset != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: widget.onGoToReset,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gradientStart,
                      side: const BorderSide(color: AppColors.gradientStart),
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
                    style: GoogleFonts.outfit(color: AppColors.gradientStart),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
