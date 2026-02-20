import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/app_apis.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import '../../../core/user_cache.dart';
import '../../../models/user_profile.dart';
import '../auth/widgets/auth_input_decoration.dart';
import '../auth/widgets/primary_button.dart';

/// Configuración: editar datos personales (nombres, apellidos, correo).
/// Si se cambia el correo, se informa que debe validar el nuevo correo por enlace, cerrar sesión e iniciar sesión de nuevo.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.apis,
    required this.onLogout,
  });

  final AppApis apis;
  final VoidCallback onLogout;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  UserProfile? _profile;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await widget.apis.profile.getMe();
      if (!mounted) return;
      if (res.success && res.data != null) {
        final p = res.data!;
        setState(() {
          _profile = p;
          _nombresCtrl.text = p.nombres ?? '';
          _apellidosCtrl.text = p.apellidos ?? '';
          _emailCtrl.text = p.email ?? '';
          _loading = false;
        });
      } else {
        await _fillFromCache();
      }
    } on DioException catch (_) {
      if (!mounted) return;
      await _fillFromCache();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'No se pudo cargar el perfil. Puedes editar los datos abajo.';
      });
    } catch (e) {
      if (mounted) {
        await _fillFromCache();
        if (mounted) setState(() {
          _loading = false;
          _error = 'No se pudo cargar el perfil. Puedes editar los datos abajo.';
        });
      }
    }
  }

  Future<void> _fillFromCache() async {
    final email = await UserCache.getEmail();
    final displayName = await UserCache.getDisplayName();
    if (!mounted) return;
    if (_profile == null && (email != null || displayName != null)) {
      final parts = displayName?.trim().split(RegExp(r'\s+')) ?? [];
      final nombres = parts.isNotEmpty ? parts.first : '';
      final apellidos = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      setState(() {
        _loading = false;
        _profile = UserProfile(id: '', email: email, nombres: nombres.isEmpty ? null : nombres, apellidos: apellidos.isEmpty ? null : apellidos);
        _nombresCtrl.text = nombres;
        _apellidosCtrl.text = apellidos;
        _emailCtrl.text = email ?? '';
        _error = _error ?? 'No se pudo cargar el perfil desde el servidor. Los datos mostrados son los guardados al iniciar sesión.';
      });
    } else if (_profile == null) {
      setState(() {
        _loading = false;
        _error = _error ?? 'No se pudo cargar el perfil. Puedes completar los datos abajo y guardar.';
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _error = null;
      _saving = true;
    });
    final nombres = _nombresCtrl.text.trim();
    final apellidos = _apellidosCtrl.text.trim();
    final newEmail = _emailCtrl.text.trim();
    final emailChanged = _profile?.email != null &&
        newEmail.isNotEmpty &&
        _profile!.email!.toLowerCase() != newEmail.toLowerCase();

    try {
      // PATCH /auth/me: solo datos personales (sin email)
      final res = await widget.apis.profile.updateProfile(
        nombres: nombres.isEmpty ? null : nombres,
        apellidos: apellidos.isEmpty ? null : apellidos,
      );
      if (!mounted) return;
      if (!res.success) {
        setState(() {
          _saving = false;
          _error = res.message ?? 'No se pudieron guardar los datos.';
        });
        return;
      }
      if (res.data != null) {
        setState(() => _profile = res.data);
      }

      if (emailChanged) {
        final emailRes = await widget.apis.profile.requestEmailChange(newEmail);
        if (!mounted) return;
        if (emailRes.success) {
          setState(() => _saving = false);
          _showEmailChangeDialog();
        } else {
          setState(() {
            _saving = false;
            _error = _emailChangeErrorMessage(emailRes.errorCode) ?? emailRes.message ?? 'No se pudo solicitar el cambio de correo.';
          });
        }
        return;
      }

      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Datos guardados.', style: GoogleFonts.outfit()),
            backgroundColor: MeEncontrastePalette.primary600,
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) setState(() {
        _saving = false;
        _error = e.response?.statusCode == 404
            ? 'El servidor aún no permite actualizar el perfil. Intenta más tarde.'
            : (e.response?.data is Map ? (e.response!.data['message']?.toString()) : null) ?? 'No se pudieron guardar los datos.';
      });
    } catch (e) {
      if (mounted) setState(() {
        _saving = false;
        _error = 'No se pudieron guardar los datos.';
      });
    }
  }

  String? _emailChangeErrorMessage(String? errorCode) {
    switch (errorCode) {
      case 'SAME_EMAIL':
        return 'El nuevo correo es igual al actual.';
      case 'EMAIL_IN_USE':
        return 'Ese correo ya está en uso por otra cuenta.';
      case 'EMAIL_SEND_FAILED':
        return 'No se pudo enviar el correo de verificación. Intenta más tarde.';
      default:
        return null;
    }
  }

  void _showEmailChangeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _EmailChangeDialog(
        onLogout: () {
          Navigator.of(dialogContext).pop();
          widget.onLogout();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MeEncontrastePalette.gray50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Configuración',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: MeEncontrastePalette.gray900,
          ),
        ),
        iconTheme: const IconThemeData(color: MeEncontrastePalette.gray900),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    if (_error != null) ...[
                      Text(
                        _error!,
                        style: GoogleFonts.outfit(color: MeEncontrastePalette.error500, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      'Datos personales',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: MeEncontrastePalette.gray900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nombresCtrl,
                      decoration: authInputDecoration(context, label: 'Nombres', hint: 'Ej. Juan'),
                      style: authInputTextStyle(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _apellidosCtrl,
                      decoration: authInputDecoration(context, label: 'Apellidos', hint: 'Ej. Pérez'),
                      style: authInputTextStyle(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: authInputDecoration(context, label: 'Correo', hint: 'correo@ejemplo.cl'),
                      style: authInputTextStyle(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Si cambias el correo, recibirás un enlace de verificación. Debes validarlo, cerrar sesión e iniciar sesión con el nuevo correo.',
                      style: GoogleFonts.outfit(fontSize: 12, color: MeEncontrastePalette.gray500, height: 1.3),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: _saving ? 'Guardando...' : 'Guardar cambios',
                      onPressed: _saving ? null : _save,
                      loading: _saving,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Modal de cambio de correo: logo, texto explicativo y contador 7 s que fuerza cierre de sesión.
class _EmailChangeDialog extends StatefulWidget {
  const _EmailChangeDialog({required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<_EmailChangeDialog> createState() => _EmailChangeDialogState();
}

class _EmailChangeDialogState extends State<_EmailChangeDialog> {
  static const int _countdownSeconds = 7;
  int _remaining = _countdownSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining--;
        if (_remaining <= 0) {
          _timer?.cancel();
          widget.onLogout();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _remaining <= 0 ? 0.0 : _remaining / _countdownSeconds;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo de la app
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/logo.png',
                height: 72,
                width: 72,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: MeEncontrastePalette.primary100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.mark_email_read_rounded, size: 40, color: MeEncontrastePalette.primary600),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Solicitud de cambio de correo enviada',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: MeEncontrastePalette.gray900,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Para completar el cambio de correo, sigue estos pasos:',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: MeEncontrastePalette.gray700,
              ),
            ),
            const SizedBox(height: 12),
            _Step(text: 'Revisa la bandeja de entrada del nuevo correo que indicaste.'),
            _Step(text: 'Abre el correo y haz clic en el enlace de verificación.'),
            _Step(text: 'Por seguridad, cerraremos tu sesión en unos segundos.'),
            _Step(text: 'Luego inicia sesión de nuevo usando tu nuevo correo y tu contraseña.'),
            const SizedBox(height: 24),
            // Barra de progreso y contador
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: MeEncontrastePalette.gray200,
                valueColor: const AlwaysStoppedAnimation<Color>(MeEncontrastePalette.primary600),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_remaining > 0) ...[
                  Icon(Icons.timer_outlined, size: 20, color: MeEncontrastePalette.primary600),
                  const SizedBox(width: 8),
                  Text(
                    'Cerrando sesión en $_remaining segundos…',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MeEncontrastePalette.primary600,
                    ),
                  ),
                ] else
                  Text(
                    'Cerrando sesión…',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MeEncontrastePalette.primary600,
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

class _Step extends StatelessWidget {
  const _Step({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: MeEncontrastePalette.primary500,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 13,
                height: 1.4,
                color: MeEncontrastePalette.gray600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
