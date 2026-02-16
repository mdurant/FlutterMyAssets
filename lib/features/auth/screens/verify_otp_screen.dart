import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_error_helper.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({
    super.key,
    required this.email,
    required this.purpose,
    required this.onVerify,
    this.onResendOtp,
  });

  final String email;
  final String purpose;
  final Future<void> Function(String code) onVerify;
  /// Llama a login solo con email para que el backend reenvíe el OTP (según API).
  final Future<void> Function()? onResendOtp;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  bool _resending = false;
  String? _error;
  String? _resendMessage;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _resendOtp() async {
    if (widget.onResendOtp == null) return;
    setState(() {
      _error = null;
      _resendMessage = null;
      _resending = true;
    });
    try {
      await widget.onResendOtp!();
      if (mounted) setState(() {
        _resending = false;
        _resendMessage = 'Código reenviado. Revisa tu correo (y carpeta spam).';
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
    final code = _codeCtrl.text.trim().replaceAll(' ', '');
    if (code.length != 6) {
      setState(() => _error = 'El código OTP tiene 6 dígitos');
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.onVerify(code);
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
                'Código de verificación',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresa los 6 dígitos que enviamos a ${widget.email}',
                style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Si no lo recibiste, revisa la carpeta de spam.',
                style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
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
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Código OTP',
                  hintText: '000000',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: _loading ? 'Verificando...' : 'Continuar',
                  onPressed: _loading ? () {} : _submit,
                ),
              ),
              if (widget.onResendOtp != null) ...[
                const SizedBox(height: 20),
                Center(
                  child: TextButton.icon(
                    onPressed: _resending ? null : _resendOtp,
                    icon: Icon(
                      Icons.refresh,
                      size: 18,
                      color: _resending ? AppColors.textSecondary : AppColors.gradientStart,
                    ),
                    label: Text(
                      _resending ? 'Reenviando...' : 'Reenviar código OTP',
                      style: GoogleFonts.outfit(
                        color: _resending ? AppColors.textSecondary : AppColors.gradientStart,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
