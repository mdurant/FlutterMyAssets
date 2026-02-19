import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/app_apis.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import 'widgets/tab_entrance_animation.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.apis});

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
                  'Avisos',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: MeEncontrastePalette.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tus notificaciones',
                  style: GoogleFonts.outfit(fontSize: 15, color: MeEncontrastePalette.gray600),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_none, size: 64, color: MeEncontrastePalette.gray400),
                        const SizedBox(height: 16),
                        Text(
                          'Sin avisos',
                          style: GoogleFonts.outfit(fontSize: 16, color: MeEncontrastePalette.gray600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aquí verás actualizaciones de tus solicitudes y mensajes.',
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
