import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_error_helper.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    super.key,
    this.email,
    required this.onVerify,
    required this.onResend,
  });

  final String? email;
  final Future<void> Function(String token) onVerify;
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
      await widget.onVerify(token);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verificar correo',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.email != null
                    ? 'Ingresa el código que enviamos a ${widget.email}'
                    : 'Ingresa el código que enviamos a tu correo.',
                style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (_resendMessage != null) ...[
                Text(
                  _resendMessage!,
                  style: GoogleFonts.outfit(color: Colors.green, fontSize: 13),
                ),
                const SizedBox(height: 12),
              ],
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _tokenCtrl,
                decoration: const InputDecoration(
                  labelText: 'Código de verificación',
                  hintText: 'Pega aquí el token del correo',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: _loading ? 'Verificando...' : 'Verificar',
                  onPressed: _loading ? () {} : _submit,
                ),
              ),
              const SizedBox(height: 16),
              if (widget.onResend != null)
                Center(
                  child: TextButton.icon(
                    onPressed: _resending ? null : _handleResend,
                    icon: Icon(
                      Icons.refresh,
                      size: 18,
                      color: _resending ? AppColors.textSecondary : AppColors.gradientStart,
                    ),
                    label: Text(
                      _resending ? 'Reenviando...' : 'Reenviar código',
                      style: GoogleFonts.outfit(
                        color: _resending ? AppColors.textSecondary : AppColors.gradientStart,
                        fontWeight: FontWeight.w600,
                      ),
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
