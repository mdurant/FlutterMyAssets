import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import '../auth/widgets/primary_button.dart';
import 'widgets/tab_entrance_animation.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MeEncontrastePalette.gray50,
      body: SafeArea(
        child: TabEntranceAnimation(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cuenta',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: MeEncontrastePalette.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gestiona tu perfil y preferencias',
                  style: GoogleFonts.outfit(fontSize: 15, color: MeEncontrastePalette.gray600),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Center(
                    child: PrimaryButton(
                      label: 'Cerrar sesión',
                      onPressed: onLogout,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
