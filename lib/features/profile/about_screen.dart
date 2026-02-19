import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/me_encontraste_palette.dart';

/// Información de la app: logo, versión, año, empresa, correo de soporte.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String appVersion = '1.0.0';
  static const String year = '2026';
  static const String companyName = 'IntegralTech Services Sp';
  static const String supportEmail = 'soporte@integraltech.cl';

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
          'Acerca de',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: MeEncontrastePalette.gray900,
          ),
        ),
        iconTheme: const IconThemeData(color: MeEncontrastePalette.gray900),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: MeEncontrastePalette.primary100,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: MeEncontrastePalette.primary200.withValues(alpha: 0.6),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.home_rounded,
                    size: 48,
                    color: MeEncontrastePalette.primary600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Me encontraste',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: MeEncontrastePalette.gray900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Versión $appVersion',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: MeEncontrastePalette.gray600,
                ),
              ),
              const SizedBox(height: 32),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Año',
                value: year,
              ),
              const SizedBox(height: 16),
              _InfoRow(
                icon: Icons.business_outlined,
                label: 'Empresa',
                value: companyName,
              ),
              const SizedBox(height: 16),
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'Soporte',
                value: supportEmail,
                isEmail: true,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isEmail = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isEmail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: MeEncontrastePalette.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: MeEncontrastePalette.gray200.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: MeEncontrastePalette.primary600),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: MeEncontrastePalette.gray500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: MeEncontrastePalette.gray900,
                  ),
                ),
              ],
            ),
          ),
          if (isEmail)
            IconButton(
              icon: const Icon(Icons.open_in_new, size: 20),
              onPressed: () async {
                final uri = Uri.parse('mailto:$value');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
            ),
        ],
      ),
    );
  }
}
