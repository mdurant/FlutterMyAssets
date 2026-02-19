import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/app_apis.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import '../../../models/property.dart';
import '../auth/widgets/primary_button.dart';

class PropertyDetailScreen extends StatefulWidget {
  const PropertyDetailScreen({
    super.key,
    required this.propertyId,
    required this.apis,
  });

  final String propertyId;
  final AppApis apis;

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  Property? _property;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await widget.apis.properties.get(widget.propertyId);
      if (!mounted) return;
      if (res.success && res.data != null) {
        setState(() {
          _property = res.data;
          _loading = false;
        });
      } else {
        setState(() {
          _error = res.message ?? 'No se pudo cargar la propiedad.';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MeEncontrastePalette.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detalle',
          style: GoogleFonts.outfit(
            color: MeEncontrastePalette.gray900,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: MeEncontrastePalette.gray900),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center, style: GoogleFonts.outfit(color: MeEncontrastePalette.error500)),
                        const SizedBox(height: 16),
                        TextButton(onPressed: _load, child: const Text('Reintentar')),
                      ],
                    ),
                  ),
                )
              : _property == null
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_property!.imageUrls != null && _property!.imageUrls!.isNotEmpty)
                            _buildImageSection()
                          else
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: MeEncontrastePalette.gray200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Icon(Icons.home_rounded, size: 64, color: MeEncontrastePalette.gray400),
                              ),
                            ),
                          const SizedBox(height: 24),
                          if (_property!.price != null)
                            Text(
                              '\$${_property!.price!.toStringAsFixed(0)} / mes',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: MeEncontrastePalette.primary600,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            _property!.title ?? _property!.address ?? 'Propiedad',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: MeEncontrastePalette.gray900,
                            ),
                          ),
                          if (_property!.address != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 20, color: MeEncontrastePalette.gray500),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _property!.address!,
                                    style: GoogleFonts.outfit(fontSize: 14, color: MeEncontrastePalette.gray600),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (_property!.description != null && _property!.description!.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text(
                              _property!.description!,
                              style: GoogleFonts.outfit(fontSize: 15, color: MeEncontrastePalette.gray700, height: 1.5),
                            ),
                          ],
                          if (_property!.bedrooms != null || _property!.bathrooms != null) ...[
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                if (_property!.bedrooms != null) _chip(Icons.bed_outlined, '${_property!.bedrooms} dorm'),
                                if (_property!.bathrooms != null) _chip(Icons.bathroom_outlined, '${_property!.bathrooms} baño'),
                              ],
                            ),
                          ],
                          if (_property!.facilities != null && _property!.facilities!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Comodidades',
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: MeEncontrastePalette.gray900),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _property!.facilities!
                                  .map((f) => Chip(
                                        label: Text(f, style: GoogleFonts.outfit(fontSize: 13)),
                                        backgroundColor: MeEncontrastePalette.primary50,
                                      ))
                                  .toList(),
                            ),
                          ],
                          if (_property!.riskScore != null) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(Icons.shield_outlined, size: 20, color: MeEncontrastePalette.primary600),
                                const SizedBox(width: 8),
                                Text(
                                  'Riesgo: ${_property!.riskScore!.toStringAsFixed(1)}',
                                  style: GoogleFonts.outfit(fontSize: 14, color: MeEncontrastePalette.gray700),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 32),
                          PrimaryButton(
                            label: 'Solicitar arriendo',
                            onPressed: () {
                              // TODO: navegar a pantalla de solicitud de arriendo (bookings)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Próximamente: solicitud de arriendo', style: GoogleFonts.outfit())),
                              );
                            },
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildImageSection() {
    final urls = _property!.imageUrls!;
    String url = urls.first;
    if (url.startsWith('/')) url = kBaseUrlForAssets + url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: url.startsWith('http')
          ? Image.network(url, height: 220, width: double.infinity, fit: BoxFit.cover)
          : Container(
              height: 220,
              color: MeEncontrastePalette.gray200,
              child: Center(child: Icon(Icons.home_rounded, size: 64, color: MeEncontrastePalette.gray400)),
            ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: MeEncontrastePalette.gray600),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.outfit(fontSize: 14, color: MeEncontrastePalette.gray700)),
        ],
      ),
    );
  }
}
