import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/me_encontraste_palette.dart';

/// Propiedades vistas recientemente (placeholder).
class RecentViewedScreen extends StatelessWidget {
  const RecentViewedScreen({super.key});

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
          'Vistos recientemente',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: MeEncontrastePalette.gray900,
          ),
        ),
        iconTheme: const IconThemeData(color: MeEncontrastePalette.gray900),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 64, color: MeEncontrastePalette.gray400),
              const SizedBox(height: 16),
              Text(
                'Aquí verás las propiedades que hayas visitado.',
                style: GoogleFonts.outfit(fontSize: 16, color: MeEncontrastePalette.gray600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
