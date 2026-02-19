import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/app_apis.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import '../../../core/user_cache.dart';
import '../../../models/user_profile.dart';
import 'widgets/tab_entrance_animation.dart';
import '../profile/about_screen.dart';
import '../profile/settings_screen.dart';
import '../profile/notification_preferences_screen.dart';
import '../profile/recent_viewed_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.apis,
    required this.onLogout,
  });

  final AppApis apis;
  final VoidCallback onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _loading = true;
  String? _error;
  String? _localAvatarPath;
  bool _uploadingAvatar = false;
  String? _cacheDisplayName;
  String? _cacheEmail;

  @override
  void initState() {
    super.initState();
    _loadCachedUserThenProfile();
  }

  Future<void> _loadCachedUserThenProfile() async {
    await _loadCachedUser();
    if (!mounted) return;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await widget.apis.profile.getMe();
      if (!mounted) return;
      if (res.success && res.data != null) {
        setState(() {
          _profile = res.data;
          _loading = false;
        });
      } else {
        await _loadCachedUser();
        if (!mounted) return;
        setState(() {
          _profile = null;
          _loading = false;
          _error = _cacheEmail != null ? null : (res.message ?? 'No se pudo cargar el perfil');
        });
      }
    } catch (e) {
      await _loadCachedUser();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _profile = null;
        _error = _cacheEmail != null ? null : 'No se pudo cargar el perfil desde el servidor';
      });
    }
  }

  Future<void> _loadCachedUser() async {
    final email = await UserCache.getEmail();
    final displayName = await UserCache.getDisplayName();
    if (mounted) {
      setState(() {
        _cacheEmail = email;
        _cacheDisplayName = displayName?.trim().isEmpty == true ? null : displayName;
      });
    }
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    Navigator.of(context).pop();
    final picker = ImagePicker();
    XFile? file;
    try {
      file = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      final msg = e.code == 'channel-error' || e.message?.contains('channel') == true
          ? 'El selector de fotos no está listo. Cierra la app por completo y ábrela de nuevo, luego intenta otra vez.'
          : (e.message ?? 'No se pudo abrir la galería o cámara.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    if (file == null || !mounted) return;
    final path = file.path;
    setState(() {
      _localAvatarPath = path;
      _uploadingAvatar = true;
    });
    try {
      final res = await widget.apis.profile.uploadAvatar(path);
      if (!mounted) return;
      if (res.success && res.data != null) {
        setState(() {
          _profile = _profile != null
              ? UserProfile(
                  id: _profile!.id,
                  email: _profile!.email,
                  nombres: _profile!.nombres,
                  apellidos: _profile!.apellidos,
                  avatarUrl: res.data,
                )
              : null;
          _uploadingAvatar = false;
          _localAvatarPath = null;
        });
      } else {
        setState(() => _uploadingAvatar = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res.message ?? 'Error al subir la foto')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    }
  }

  void _showAvatarSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: MeEncontrastePalette.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cambiar foto de perfil',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: MeEncontrastePalette.gray900,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: MeEncontrastePalette.primary600),
                title: Text('Galería', style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                onTap: () => _pickAndUploadAvatar(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: MeEncontrastePalette.primary600),
                title: Text('Cámara', style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                onTap: () => _pickAndUploadAvatar(ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MeEncontrastePalette.gray50,
      body: SafeArea(
        child: TabEntranceAnimation(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildMenuList(),
                        const SizedBox(height: 24),
                        _buildSignOut(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final name = _profile?.fullName ?? _cacheDisplayName ?? 'Usuario';
    final email = _profile?.email ?? _cacheEmail ?? '—';
    final avatarUrl = _localAvatarPath != null
        ? null
        : _profile?.avatarUrl;
    String? resolvedAvatarUrl = avatarUrl;
    if (resolvedAvatarUrl != null && resolvedAvatarUrl.startsWith('/')) {
      resolvedAvatarUrl = kBaseUrlForAssets + resolvedAvatarUrl;
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _uploadingAvatar ? null : _showAvatarSourceSheet,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(scale: value, child: child),
              );
            },
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: MeEncontrastePalette.primary100,
                  backgroundImage: _localAvatarPath != null
                      ? FileImage(File(_localAvatarPath!))
                      : resolvedAvatarUrl != null && resolvedAvatarUrl.startsWith('http')
                          ? NetworkImage(resolvedAvatarUrl) as ImageProvider
                          : null,
                  child: _localAvatarPath == null &&
                          (resolvedAvatarUrl == null || !resolvedAvatarUrl.startsWith('http'))
                      ? Text(
                          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                          style: GoogleFonts.outfit(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: MeEncontrastePalette.primary600,
                          ),
                        )
                      : null,
                ),
                if (_uploadingAvatar)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: MeEncontrastePalette.primary600,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: MeEncontrastePalette.primary600,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: MeEncontrastePalette.primary600.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: MeEncontrastePalette.gray900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: GoogleFonts.outfit(fontSize: 14, color: MeEncontrastePalette.gray600),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: GoogleFonts.outfit(fontSize: 12, color: MeEncontrastePalette.error500),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        Divider(color: MeEncontrastePalette.gray200, height: 1),
      ],
    );
  }

  Widget _buildMenuList() {
    final items = [
      _MenuItem(icon: Icons.settings_outlined, label: 'Configuración', onTap: () => _push(SettingsScreen())),
      _MenuItem(icon: Icons.notifications_outlined, label: 'Notificaciones', onTap: () => _push(NotificationPreferencesScreen())),
      _MenuItem(icon: Icons.history, label: 'Vistos recientemente', onTap: () => _push(RecentViewedScreen())),
      _MenuItem(icon: Icons.info_outline_rounded, label: 'Acerca de', onTap: () => _push(AboutScreen())),
    ];

    return Column(
      children: List.generate(items.length, (i) {
        return TweenAnimationBuilder<double>(
          key: ValueKey(items[i].label),
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (i * 60)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _MenuTile(
              icon: items[i].icon,
              label: items[i].label,
              onTap: items[i].onTap,
            ),
          ),
        );
      }),
    );
  }

  void _push(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Widget _buildSignOut() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: Center(
        child: TextButton(
          onPressed: () {
            _showSignOutConfirmation();
          },
          child: Text(
            'Cerrar sesión',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: MeEncontrastePalette.error500,
            ),
          ),
        ),
      ),
    );
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar sesión', style: GoogleFonts.outfit()),
        content: Text(
          '¿Estás seguro de que deseas salir?',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar', style: GoogleFonts.outfit(color: MeEncontrastePalette.gray600)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onLogout();
            },
            child: Text('Cerrar sesión', style: GoogleFonts.outfit(color: MeEncontrastePalette.error500, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MeEncontrastePalette.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: MeEncontrastePalette.primary600),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: MeEncontrastePalette.gray900,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 22, color: MeEncontrastePalette.gray400),
            ],
          ),
        ),
      ),
    );
  }
}
