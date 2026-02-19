import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/app_apis.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import 'widgets/tab_entrance_animation.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.apis});

  final AppApis apis;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await widget.apis.favorites.list();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = res.success ? null : (res.message ?? 'Error al cargar favoritos.');
      });
    } catch (e) {
      if (mounted) setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

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
                  'Favoritos',
                  style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: MeEncontrastePalette.gray900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tus propiedades guardadas',
                style: GoogleFonts.outfit(fontSize: 15, color: MeEncontrastePalette.gray600),
              ),
              const SizedBox(height: 24),
              if (_loading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, style: GoogleFonts.outfit(color: MeEncontrastePalette.error500), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        TextButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_border, size: 64, color: MeEncontrastePalette.gray400),
                        const SizedBox(height: 16),
                        Text(
                          'Aún no tienes favoritos',
                          style: GoogleFonts.outfit(fontSize: 16, color: MeEncontrastePalette.gray600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Explora propiedades y guarda las que te interesen.',
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
