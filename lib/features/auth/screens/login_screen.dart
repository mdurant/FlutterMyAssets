import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_error_helper.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_input_decoration.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
    required this.onPasswordRecovery,
    this.onRequestOtp,
  });

  final Future<void> Function(String email, String password) onLogin;
  final VoidCallback onRegister;
  final VoidCallback onPasswordRecovery;
  /// Solicitar código OTP al correo (POST /auth/login solo con email). Si se completa sin error, la app navega a la pantalla OTP.
  final Future<void> Function(String email)? onRequestOtp;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await widget.onLogin(_emailCtrl.text.trim(), _passwordCtrl.text);
      if (!mounted) return;
      setState(() => _error = null);
    } catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requestOtp() async {
    setState(() => _error = null);
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Ingresa un correo válido');
      return;
    }
    final onRequestOtp = widget.onRequestOtp;
    if (onRequestOtp == null) return;
    setState(() => _loading = true);
    try {
      await onRequestOtp(email);
      if (!mounted) return;
      setState(() => _error = null);
    } catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecoration(String label, {String? hint, Widget? suffixIcon}) {
    return authInputDecoration(context, label: label, hint: hint, suffixIcon: suffixIcon);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: '¡Bienvenido de nuevo!',
      subtitle: 'Inicia sesión con tu correo y contraseña para continuar.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              Text(
                _error!,
                style: GoogleFonts.outfit(
                  color: MeEncontrastePalette.error500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: authInputTextStyle(),
              decoration: _inputDecoration('Correo', hint: 'tu@correo.com'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                if (!v.contains('@')) return 'Correo no válido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              style: authInputTextStyle(),
              decoration: _inputDecoration(
                'Contraseña',
                hint: '••••••••',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: MeEncontrastePalette.gray500,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v ?? false),
                    activeColor: MeEncontrastePalette.primary600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Recordarme',
                  style: GoogleFonts.outfit(color: MeEncontrastePalette.gray700, fontSize: 14),
                ),
                const Spacer(),
                TextButton(
                  onPressed: widget.onPasswordRecovery,
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: GoogleFonts.outfit(
                      color: MeEncontrastePalette.primary600,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: _loading ? 'Entrando...' : 'Iniciar sesión',
              onPressed: _submit,
              loading: _loading,
            ),
            if (widget.onRequestOtp != null) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _loading ? null : _requestOtp,
                  child: Text(
                    'Iniciar sesión con código',
                    style: GoogleFonts.outfit(
                      color: MeEncontrastePalette.primary600,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Divider(color: MeEncontrastePalette.gray300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'O',
                    style: GoogleFonts.outfit(color: MeEncontrastePalette.gray500, fontSize: 14),
                  ),
                ),
                Expanded(child: Divider(color: MeEncontrastePalette.gray300)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialButton(icon: Icons.facebook_rounded, color: const Color(0xFF1877F2)),
                const SizedBox(width: 16),
                _SocialButton(icon: Icons.g_mobiledata_rounded, color: MeEncontrastePalette.gray900),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿No tienes cuenta? ',
                  style: GoogleFonts.outfit(color: MeEncontrastePalette.gray600, fontSize: 14),
                ),
                TextButton(
                  onPressed: widget.onRegister,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text(
                    'Regístrate',
                    style: GoogleFonts.outfit(
                      color: MeEncontrastePalette.primary600,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: MeEncontrastePalette.gray300),
          ),
          child: Icon(icon, size: 28, color: color),
        ),
      ),
    );
  }
}
