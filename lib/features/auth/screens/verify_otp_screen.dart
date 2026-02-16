import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_error_helper.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/primary_button.dart';

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
  final Future<void> Function()? onResendOtp;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  static const int _digitCount = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _loading = false;
  bool _resending = false;
  String? _error;
  String? _resendMessage;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_digitCount, (_) => TextEditingController());
    _focusNodes = List.generate(_digitCount, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String _getCode() =>
      _controllers.map((c) => c.text.trim()).join().replaceAll(' ', '');

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
        _error = e is DioException && widget.purpose == 'LOGIN'
            ? messageForLoginOtpRequest(e)
            : apiErrorMessage(e);
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    final code = _getCode();
    if (code.length != _digitCount) {
      setState(() => _error = 'Ingresa los 6 dígitos del código');
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

  void _onDigitChanged(int index, String value) {
    if (value.length == 1) {
      if (index < _digitCount - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _submit();
      }
    }
  }

  KeyEventResult _onKey(KeyEvent event, FocusNode node, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Verifica tu correo',
      subtitle: 'Ingresa el código de 6 dígitos que enviamos a tu dirección de correo.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 8.0;
          final availableWidth = constraints.maxWidth;
          final boxSize = ((availableWidth - gap * (_digitCount - 1)) / _digitCount).clamp(40.0, 52.0);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_digitCount, (index) {
                    return Padding(
                      padding: EdgeInsets.only(right: index < _digitCount - 1 ? gap : 0),
                      child: Focus(
                        onKeyEvent: (node, event) => _onKey(event, node, index),
                        child: _OtpBox(
                          size: boxSize,
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          onChanged: (v) => _onDigitChanged(index, v),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿No recibiste el código? ',
                    style: GoogleFonts.outfit(
                      color: MeEncontrastePalette.gray600,
                      fontSize: 14,
                    ),
                  ),
                  if (widget.onResendOtp != null)
                    GestureDetector(
                      onTap: _resending ? null : _resendOtp,
                      child: Text(
                        _resending ? 'Reenviando...' : 'Reenviar código',
                        style: GoogleFonts.outfit(
                          color: MeEncontrastePalette.error500,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Reenviar código',
                      style: GoogleFonts.outfit(
                        color: MeEncontrastePalette.gray400,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: _loading ? 'Verificando...' : 'Verificar',
                onPressed: _submit,
                loading: _loading,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OtpBox extends StatefulWidget {
  const _OtpBox({
    required this.size,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final double size;
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String value) onChanged;

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_updateBorder);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_updateBorder);
    super.dispose();
  }

  void _updateBorder() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox(
      width: s,
      height: s * 1.2,
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.outfit(
          color: MeEncontrastePalette.dark,
          fontSize: (s * 0.45).clamp(18.0, 24.0),
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: MeEncontrastePalette.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: MeEncontrastePalette.gray300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: MeEncontrastePalette.primary600, width: 2),
          ),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
