import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/app_apis.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import '../../../models/property.dart';
import 'property_detail_screen.dart';
import 'widgets/tab_entrance_animation.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, required this.apis});

  final AppApis apis;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Property> _list = [];
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
      final res = await widget.apis.properties.list();
      if (!mounted) return;
      if (res.success && res.data != null) {
        setState(() {
          _list = res.data!;
          _loading = false;
        });
      } else {
        setState(() {
          _error = res.message ?? 'No se pudieron cargar las propiedades.';
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
      backgroundColor: MeEncontrastePalette.gray50,
      body: SafeArea(
        child: TabEntranceAnimation(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          child: CustomScrollView(
            slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explorar',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: MeEncontrastePalette.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Encuentra tu próximo hogar',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: MeEncontrastePalette.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        _error!,
                        style: GoogleFonts.outfit(color: MeEncontrastePalette.error500, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_list.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home_work_outlined, size: 64, color: MeEncontrastePalette.gray400),
                      const SizedBox(height: 16),
                      Text(
                        'Aún no hay propiedades publicadas',
                        style: GoogleFonts.outfit(color: MeEncontrastePalette.gray600, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return TweenAnimationBuilder<double>(
                        key: ValueKey(_list[index].id),
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 300 + (index * 80).clamp(0, 300)),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: _TapScaleChild(
                          child: _PropertyCard(
                            property: _list[index],
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PropertyDetailScreen(
                                  propertyId: _list[index].id,
                                  apis: widget.apis,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: _list.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TapScaleChild extends StatefulWidget {
  const _TapScaleChild({required this.child});

  final Widget child;

  @override
  State<_TapScaleChild> createState() => _TapScaleChildState();
}

class _TapScaleChildState extends State<_TapScaleChild> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({required this.property, required this.onTap});

  final Property property;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String? imageUrl = property.imageUrls != null && property.imageUrls!.isNotEmpty
        ? property.imageUrls!.first
        : null;
    if (imageUrl != null && imageUrl.startsWith('/')) {
      imageUrl = kBaseUrlForAssets + imageUrl;
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                color: MeEncontrastePalette.gray200,
                child: imageUrl != null && imageUrl.startsWith('http')
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Center(
                        child: Icon(Icons.home_rounded, size: 48, color: MeEncontrastePalette.gray400),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (property.price != null)
                    Text(
                      '\$${property.price!.toStringAsFixed(0)} / mes',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MeEncontrastePalette.primary600,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    property.title ?? property.address ?? 'Propiedad',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: MeEncontrastePalette.gray900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (property.address != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: MeEncontrastePalette.gray500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.address!,
                            style: GoogleFonts.outfit(fontSize: 13, color: MeEncontrastePalette.gray600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (property.bedrooms != null || property.bathrooms != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (property.bedrooms != null) ...[
                          Icon(Icons.bed_outlined, size: 18, color: MeEncontrastePalette.gray500),
                          const SizedBox(width: 4),
                          Text('${property.bedrooms}', style: GoogleFonts.outfit(fontSize: 13, color: MeEncontrastePalette.gray600)),
                          const SizedBox(width: 12),
                        ],
                        if (property.bathrooms != null) ...[
                          Icon(Icons.bathroom_outlined, size: 18, color: MeEncontrastePalette.gray500),
                          const SizedBox(width: 4),
                          Text('${property.bathrooms}', style: GoogleFonts.outfit(fontSize: 13, color: MeEncontrastePalette.gray600)),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
