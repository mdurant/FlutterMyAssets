import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/api/api_client.dart';
import 'core/api/auth_api.dart';
import 'core/api/regions_api.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart' show RegisterPayload, RegisterScreen;
import 'features/auth/screens/verify_email_screen.dart';
import 'features/auth/screens/verify_otp_screen.dart';
import 'features/auth/screens/password_recovery_screen.dart';
import 'features/auth/screens/password_reset_screen.dart';
import 'features/auth/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.dark;
    return MaterialApp(
      title: 'FlutterMyAssets',
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const AuthFlow(),
    );
  }
}

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  final ApiClient _apiClient = ApiClient();
  late final AuthApi _authApi = AuthApi(_apiClient);
  late final RegionsApi _regionsApi = RegionsApi(_apiClient);

  void _goToWelcome() {
    setState(() {});
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => _buildWelcome()),
      (r) => false,
    );
  }

  Widget _buildWelcome() {
    return WelcomeScreen(
      onGetStarted: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LoginScreen(
              onLogin: _onLogin,
              onRegister: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RegisterScreen(
                    onRegister: _onRegister,
                    onLogin: () => Navigator.of(context).pop(),
                    getRegions: _regionsApi.getRegions,
                    getComunas: _regionsApi.getComunas,
                  ),
                ),
              ),
              onPasswordRecovery: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PasswordRecoveryScreen(
                    onSubmit: _onPasswordRecovery,
                    onBackToLogin: () => Navigator.of(context).pop(),
                    onGoToReset: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PasswordResetScreen(
                          onSubmit: _onPasswordReset,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onLogin(String email, String password) async {
    final res = await _authApi.login(email: email, password: password);
    if (!res.success) throw Exception(res.message ?? res.errorCode ?? 'Error al iniciar sesión');
    final data = res.data;
    if (data == null) return;
    final requiresOtp = data['requiresOtp'] as bool? ?? false;
    if (!mounted) return;
    if (requiresOtp) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(
            email: email,
            purpose: 'LOGIN',
            onVerify: (code) => _onVerifyOtp(email, code, 'LOGIN'),
            onResendOtp: () => _authApi.login(email: email),
          ),
        ),
      );
    } else {
      _saveTokensAndGoHome(data);
    }
  }

  Future<void> _onVerifyOtp(String email, String code, String purpose) async {
    final res = await _authApi.verifyOtp(email: email, code: code, purpose: purpose);
    if (!res.success) throw Exception(res.message ?? res.errorCode ?? 'Código inválido');
    final data = res.data;
    if (data != null) _saveTokensAndGoHome(data);
  }

  void _saveTokensAndGoHome(Map<String, dynamic> data) {
    final access = data['accessToken'] as String?;
    final refresh = data['refreshToken'] as String?;
    if (access != null) _apiClient.setTokens(access: access, refresh: refresh);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => HomeScreen(onLogout: _onLogout),
      ),
      (r) => false,
    );
  }

  Future<void> _onLogout() async {
    final refresh = _apiClient.refreshToken;
    if (refresh != null) {
      try {
        await _authApi.logout(refresh);
      } catch (_) {}
    }
    _apiClient.setTokens(access: null, refresh: null);
    _goToWelcome();
  }

  Future<void> _onRegister(RegisterPayload payload) async {
    final res = await _authApi.register(
      email: payload.email,
      password: payload.password,
      nombres: payload.nombres,
      apellidos: payload.apellidos,
      sexo: payload.sexo,
      fechaNacimiento: payload.fechaNacimiento,
      domicilio: payload.domicilio,
      regionId: payload.regionId,
      comunaId: payload.comunaId,
      acceptTerms: payload.acceptTerms,
    );
    if (!res.success) throw Exception(res.message ?? res.errorCode ?? 'Error al registrarse');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => VerifyEmailScreen(
          email: payload.email,
          onVerify: _onVerifyEmail,
          onResend: () => _authApi.resendVerifyEmail(payload.email),
        ),
      ),
    );
  }

  Future<void> _onVerifyEmail(String token) async {
    final res = await _authApi.verifyEmail(token);
    if (!res.success) throw Exception(res.message ?? res.errorCode ?? 'Token inválido');
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => _buildWelcome()),
      (r) => false,
    );
  }

  Future<void> _onPasswordRecovery(String email) async {
    final res = await _authApi.passwordRecovery(email);
    if (!res.success) throw Exception(res.message ?? res.errorCode ?? 'Error');
  }

  Future<void> _onPasswordReset(String token, String newPassword) async {
    final res = await _authApi.passwordReset(token: token, newPassword: newPassword);
    if (!res.success) throw Exception(res.message ?? res.errorCode ?? 'Error');
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return _buildWelcome();
  }
}
