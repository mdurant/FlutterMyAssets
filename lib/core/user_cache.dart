import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda email y nombre del usuario para mostrarlos en el perfil cuando
/// GET /users/me no exista (404) o falle. Si el canal nativo falla (ej. tras hot restart),
/// las operaciones no lanzan: el login sigue y el perfil usará "Usuario" / "—" hasta que
/// el backend devuelva datos o se reinicie la app por completo.
class UserCache {
  static const _keyEmail = 'last_user_email';
  static const _keyDisplayName = 'last_user_display_name';

  static Future<void> save({String? email, String? displayName}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (email != null) await prefs.setString(_keyEmail, email);
      if (displayName != null) await prefs.setString(_keyDisplayName, displayName);
    } on PlatformException catch (_) {
      // channel-error tras hot restart: no bloquear login
    } catch (_) {}
  }

  static Future<String?> getEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyEmail);
    } on PlatformException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getDisplayName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyDisplayName);
    } on PlatformException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyDisplayName);
    } on PlatformException catch (_) {}
    catch (_) {}
  }
}
