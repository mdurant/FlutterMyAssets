import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/api/api_client.dart';
import 'core/api/api_error_helper.dart';
import 'core/api/app_apis.dart';
import 'core/api/auth_api.dart';
import 'core/api/regions_api.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/home/post_login_gate.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart' show RegisterPayload, RegisterScreen;
import 'features/auth/screens/verify_email_screen.dart';
import 'features/auth/screens/verify_otp_screen.dart';
import 'features/auth/screens/password_recovery_screen.dart';
import 'features/auth/screens/password_reset_screen.dart';
import 'features/auth/screens/success_reset_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.dark;
    return MaterialApp(
      title: 'Me encontraste',
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
  late final AppApis _apis = AppApis(_apiClient);
  late final AuthApi _authApi = AuthApi(_apiClient);
  late final RegionsApi _regionsApi = RegionsApi(_apiClient);

  /// splash → onboarding → welcome
  String _entryStep = 'splash';

  Widget _buildLogin() {
    return LoginScreen(
      onLogin: _onLogin,
      onRequestOtp: _onRequestOtp,
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
    );
  }

  Widget _buildWelcome() {
    return WelcomeScreen(
      onGetStarted: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => _buildLogin()),
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
            onResendOtp: () => _authApi.sendLoginOtp(email),
          ),
        ),
      );
    } else {
      _saveTokensAndGoHome(data);
    }
  }

  /// Solicitar código OTP (POST /auth/send-login-otp). Contrato: FLUTTER-BACKEND-LOGIN-OTP.md.
  Future<void> _onRequestOtp(String email) async {
    try {
      final res = await _authApi.sendLoginOtp(email);
      if (!mounted) return;
      if (!res.success) {
        throw Exception(res.message ?? res.errorCode ?? 'Error al solicitar el código');
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(
            email: email,
            purpose: 'LOGIN',
            onVerify: (code) => _onVerifyOtp(email, code, 'LOGIN'),
            onResendOtp: () => _authApi.sendLoginOtp(email),
          ),
        ),
      );
    } on DioException catch (e) {
      throw Exception(messageForLoginOtpRequest(e));
    }
  }

  Future<void> _onVerifyOtp(String email, String code, String purpose) async {
    try {
      final res = await _authApi.verifyOtp(email: email, code: code, purpose: purpose);
      if (!res.success) throw Exception(res.message ?? res.errorCode ?? 'Código inválido');
      final data = res.data;
      if (!mounted) return;
      if (data != null && data['accessToken'] != null) {
        _saveTokensAndGoHome(data);
      } else {
        // OTP válido pero backend no devolvió tokens (ej. purpose EMAIL_VERIFY sin auto-login) → ir a bienvenida
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => _buildWelcome()),
          (route) => route.isFirst,
        );
      }
    } on DioException catch (e) {
      throw Exception(messageForVerifyOtpError(e));
    }
  }

  void _saveTokensAndGoHome(Map<String, dynamic> data) {
    final access = data['accessToken'] as String?;
    final refresh = data['refreshToken'] as String?;
    if (access != null) _apiClient.setTokens(access: access, refresh: refresh);
    if (!mounted) return;
    // Gate: términos (403 TERMS_NOT_ACCEPTED) y luego MainAppShell (Explorar, Favoritos, Mensajes, Avisos, Cuenta)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => PostLoginGate(apis: _apis, onLogout: _onLogout),
      ),
      (route) => route.isFirst,
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
    if (!mounted) return;
    // Volver al home (Welcome) sin eliminar AuthFlow
    Navigator.of(context).popUntil((route) => route.isFirst);
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
          onVerify: (token, email) => _onVerifyEmail(token, email),
          onResend: () => _authApi.resendVerifyEmail(payload.email),
        ),
      ),
    );
  }

  Future<void> _onVerifyEmail(String token, String email) async {
    final res = await _authApi.verifyEmail(token);
    if (!res.success) throw Exception(res.message ?? res.errorCode ?? 'Token inválido');
    if (!mounted) return;
    // Tras validar el token, ir a bienvenida para que el usuario inicie sesión (con contraseña o "Iniciar sesión con código").
    // No mostramos pantalla OTP aquí porque el backend no envía OTP en este flujo; el OTP es solo para login por código.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => _buildWelcome()),
      (route) => route.isFirst,
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SuccessResetScreen(
          onContinue: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => _buildLogin()),
              (r) => false,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_entryStep == 'splash') {
      return SplashScreen(
        onFinish: () => setState(() => _entryStep = 'onboarding'),
      );
    }
    if (_entryStep == 'onboarding') {
      return OnboardingScreen(
        onFinish: () => setState(() => _entryStep = 'welcome'),
      );
    }
    return _buildWelcome();
  }
}
