import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import '../widgets/primary_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MeEncontrastePalette.white,
      appBar: AppBar(
        backgroundColor: MeEncontrastePalette.white,
        elevation: 0,
        title: Text(
          'Me encontraste',
          style: GoogleFonts.outfit(
            color: MeEncontrastePalette.gray900,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: MeEncontrastePalette.gray900),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bienvenido',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: MeEncontrastePalette.gray900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Has iniciado sesión correctamente. Aquí irá el contenido principal de la app.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: MeEncontrastePalette.gray600,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                label: 'Cerrar sesión',
                onPressed: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
