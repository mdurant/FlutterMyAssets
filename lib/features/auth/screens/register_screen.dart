import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_error_helper.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/region.dart';
import '../../../models/comuna.dart';
import '../widgets/gradient_button.dart';

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
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _domicilioCtrl = TextEditingController();
  String _sexo = 'HOMBRE';
  DateTime _fechaNacimiento = DateTime(2000, 1, 1);
  List<Region> _regions = [];
  List<Comuna> _comunas = [];
  String? _regionId;
  String? _comunaId;
  bool _loadingRegions = true;
  bool _loadingComunas = false;
  bool _acceptTerms = false;
  bool _loading = false;
  String? _error;
  /// Error al cargar regiones o comunas (no se muestra como error general de envío).
  String? _catalogLoadError;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    setState(() {
      _loadingRegions = true;
      _catalogLoadError = null;
    });
    try {
      final list = await widget.getRegions();
      if (mounted) setState(() {
        _regions = list;
        _loadingRegions = false;
        _catalogLoadError = null;
      });
    } catch (e) {
      if (mounted) setState(() {
        _loadingRegions = false;
        _catalogLoadError = apiErrorMessage(e);
      });
    }
  }

  Future<void> _retryLoadRegions() async {
    setState(() => _catalogLoadError = null);
    await _loadRegions();
  }

  Future<void> _onRegionChanged(String? regionId) async {
    setState(() {
      _regionId = regionId;
      _comunaId = null;
      _comunas = [];
      _catalogLoadError = null;
      if (regionId == null) return;
      _loadingComunas = true;
    });
    try {
      final list = await widget.getComunas(regionId!);
      if (mounted) setState(() {
        _comunas = list;
        _loadingComunas = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _loadingComunas = false;
        _catalogLoadError = apiErrorMessage(e);
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _domicilioCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      setState(() => _error = 'Debes aceptar los términos y condiciones');
      return;
    }
    if (_regionId == null || _comunaId == null) {
      setState(() => _error = 'Selecciona región y comuna');
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.onRegister(RegisterPayload(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        nombres: _nombresCtrl.text.trim(),
        apellidos: _apellidosCtrl.text.trim(),
        sexo: _sexo,
        fechaNacimiento: _fechaNacimiento.toIso8601String().split('T').first,
        domicilio: _domicilioCtrl.text.trim(),
        regionId: _regionId!,
        comunaId: _comunaId!,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crear cuenta',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completa tus datos para registrarte.',
                  style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 24),
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Correo', hintText: 'tu@correo.com'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                    if (!v.contains('@')) return 'Correo no válido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña', hintText: 'Mín. 8 caracteres'),
                  validator: (v) {
                    if (v == null || v.length < 8) return 'Mínimo 8 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nombresCtrl,
                  decoration: const InputDecoration(labelText: 'Nombres'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _apellidosCtrl,
                  decoration: const InputDecoration(labelText: 'Apellidos'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _sexo,
                  decoration: const InputDecoration(labelText: 'Sexo'),
                  items: const [
                    DropdownMenuItem(value: 'HOMBRE', child: Text('Hombre')),
                    DropdownMenuItem(value: 'MUJER', child: Text('Mujer')),
                    DropdownMenuItem(value: 'OTRO', child: Text('Otro')),
                  ],
                  onChanged: (v) => setState(() => _sexo = v ?? 'HOMBRE'),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Fecha de nacimiento: ${_fechaNacimiento.toIso8601String().split('T').first}',
                    style: GoogleFonts.outfit(color: AppColors.textPrimary),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _fechaNacimiento,
                      firstDate: DateTime(1920),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setState(() => _fechaNacimiento = d);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _domicilioCtrl,
                  decoration: const InputDecoration(labelText: 'Domicilio'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                if (_catalogLoadError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade700, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _catalogLoadError!,
                          style: const TextStyle(color: Colors.orange, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _loadingRegions ? null : _retryLoadRegions,
                          icon: const Icon(Icons.refresh, size: 18, color: AppColors.gradientStart),
                          label: Text(
                            'Reintentar cargar regiones',
                            style: GoogleFonts.outfit(
                              color: AppColors.gradientStart,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                DropdownButtonFormField<String>(
                  value: _regionId,
                  decoration: const InputDecoration(labelText: 'Región'),
                  hint: Text(
                    _loadingRegions ? 'Cargando...' : 'Seleccione región',
                    style: GoogleFonts.outfit(color: AppColors.textSecondary),
                  ),
                  items: _regions
                      .map((r) => DropdownMenuItem(
                            value: r.id,
                            child: Text(r.nombre, style: GoogleFonts.outfit(color: AppColors.textPrimary)),
                          ))
                      .toList(),
                  onChanged: _loadingRegions ? null : _onRegionChanged,
                  validator: (v) => v == null ? 'Seleccione una región' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _comunaId,
                  decoration: const InputDecoration(labelText: 'Comuna'),
                  hint: Text(
                    _regionId == null
                        ? 'Primero seleccione región'
                        : _loadingComunas
                            ? 'Cargando...'
                            : 'Seleccione comuna',
                    style: GoogleFonts.outfit(color: AppColors.textSecondary),
                  ),
                  items: _comunas
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.nombre, style: GoogleFonts.outfit(color: AppColors.textPrimary)),
                          ))
                      .toList(),
                  onChanged: _loadingComunas || _regionId == null
                      ? null
                      : (v) => setState(() => _comunaId = v),
                  validator: (v) => v == null ? 'Seleccione una comuna' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                      activeColor: AppColors.gradientStart,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                        child: Text(
                          'Acepto los términos y condiciones',
                          style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: _loading ? 'Registrando...' : 'Registrarme',
                    onPressed: _loading ? () {} : _submit,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿Ya tienes cuenta? ', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: widget.onLogin,
                      child: Text(
                        'Iniciar sesión',
                        style: GoogleFonts.outfit(color: AppColors.gradientStart, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
