import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/app_apis.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import 'widgets/tab_entrance_animation.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key, required this.apis});

  final AppApis apis;

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
                  'Mensajes',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: MeEncontrastePalette.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Conversaciones con propietarios',
                  style: GoogleFonts.outfit(fontSize: 15, color: MeEncontrastePalette.gray600),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: MeEncontrastePalette.gray400),
                        const SizedBox(height: 16),
                        Text(
                          'Sin conversaciones',
                          style: GoogleFonts.outfit(fontSize: 16, color: MeEncontrastePalette.gray600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Al contactar una propiedad se abrirá el chat aquí.',
                          style: GoogleFonts.outfit(fontSize: 14, color: MeEncontrastePalette.gray500),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
