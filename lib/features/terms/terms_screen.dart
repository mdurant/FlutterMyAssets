import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import '../../../models/term.dart';
import '../auth/widgets/primary_button.dart';

/// Pantalla de términos y condiciones. Tras aceptar se llama [onAccepted].
class TermsScreen extends StatefulWidget {
  const TermsScreen({
    super.key,
    this.term,
    required this.onAccept,
    this.loading = false,
    this.error,
  });

  final Term? term;
  final VoidCallback onAccept;
  final bool loading;
  final String? error;

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MeEncontrastePalette.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Términos y condiciones',
          style: GoogleFonts.outfit(
            color: MeEncontrastePalette.gray900,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: MeEncontrastePalette.gray900),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              if (widget.error != null) ...[
                Text(
                  widget.error!,
                  style: GoogleFonts.outfit(color: MeEncontrastePalette.error500, fontSize: 14),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'Para usar Me encontraste debes aceptar los términos y condiciones de uso.',
                style: GoogleFonts.outfit(
                  color: MeEncontrastePalette.gray700,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              if (widget.term?.content != null && widget.term!.content!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: MeEncontrastePalette.gray50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: MeEncontrastePalette.gray200),
                      ),
                      child: Text(
                        widget.term!.content!,
                        style: GoogleFonts.outfit(
                          color: MeEncontrastePalette.gray800,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ] else
                const Spacer(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(
                    value: _accepted,
                    onChanged: (v) => setState(() => _accepted = v ?? false),
                    activeColor: MeEncontrastePalette.primary600,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _accepted = !_accepted),
                      child: Text(
                        'He leído y acepto los términos y condiciones',
                        style: GoogleFonts.outfit(color: MeEncontrastePalette.gray700, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: widget.loading ? 'Guardando...' : 'Aceptar y continuar',
                onPressed: (widget.loading || !_accepted) ? null : widget.onAccept,
                loading: widget.loading,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
