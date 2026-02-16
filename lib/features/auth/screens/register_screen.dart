import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_error_helper.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import '../../../models/region.dart';
import '../../../models/comuna.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_input_decoration.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.onRegister,
    required this.onLogin,
    required this.getRegions,
    required this.getComunas,
  });

  final Future<void> Function(RegisterPayload payload) onRegister;
  final VoidCallback onLogin;
  final Future<List<Region>> Function() getRegions;
  final Future<List<Comuna>> Function(String regionId) getComunas;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class RegisterPayload {
  String email;
  String password;
  String nombres;
  String apellidos;
  String sexo;
  String fechaNacimiento;
  String domicilio;
  String regionId;
  String comunaId;
  bool acceptTerms;

  RegisterPayload({
    required this.email,
    required this.password,
    required this.nombres,
    required this.apellidos,
    required this.sexo,
    required this.fechaNacimiento,
    required this.domicilio,
    required this.regionId,
    required this.comunaId,
    required this.acceptTerms,
  });
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      setState(() => _error = 'Debes aceptar los términos y condiciones');
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.onRegister(RegisterPayload(
        nombres: _nombresCtrl.text.trim(),
        apellidos: _apellidosCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        sexo: 'OTRO',
        fechaNacimiento: '2000-01-01',
        domicilio: '',
        regionId: '',
        comunaId: '',
        acceptTerms: _acceptTerms,
      ));
      if (!mounted) return;
      setState(() => _error = null);
    } catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _decoration(String label, {String? hint, Widget? suffixIcon}) =>
      authInputDecoration(context, label: label, hint: hint, suffixIcon: suffixIcon);

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Crear cuenta',
      subtitle: 'Completa tus datos para registrarte.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              Text(
                _error!,
                style: GoogleFonts.outfit(color: MeEncontrastePalette.error500, fontSize: 14),
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _nombresCtrl,
              style: authInputTextStyle(),
              decoration: _decoration('Nombres'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _apellidosCtrl,
              style: authInputTextStyle(),
              decoration: _decoration('Apellidos'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: authInputTextStyle(),
              decoration: _decoration('Correo', hint: 'tu@correo.com'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                if (!v.contains('@')) return 'Correo no válido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              style: authInputTextStyle(),
              decoration: _decoration(
                'Contraseña',
                hint: 'Mín. 8 caracteres',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: MeEncontrastePalette.gray500,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.length < 8) return 'Mínimo 8 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: _obscureConfirm,
              style: authInputTextStyle(),
              decoration: _decoration(
                'Repetir contraseña',
                hint: 'Repite la contraseña',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    color: MeEncontrastePalette.gray500,
                  ),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Repite tu contraseña';
                if (v != _passwordCtrl.text) return 'Las contraseñas no coinciden';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _acceptTerms,
                  onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                  activeColor: MeEncontrastePalette.primary600,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                    child: Text(
                      'Acepto los términos y condiciones',
                      style: GoogleFonts.outfit(color: MeEncontrastePalette.gray600, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: _loading ? 'Registrando...' : 'Registrarme',
              onPressed: _loading ? () {} : _submit,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('¿Ya tienes cuenta? ', style: GoogleFonts.outfit(color: MeEncontrastePalette.gray600)),
                TextButton(
                  onPressed: widget.onLogin,
                  child: Text(
                    'Iniciar sesión',
                    style: GoogleFonts.outfit(color: MeEncontrastePalette.primary600, fontWeight: FontWeight.w600),
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
