import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/api/api_error_helper.dart';
import '../../../core/api/app_apis.dart';
import '../terms/terms_screen.dart';
import 'main_app_shell.dart';

/// Tras el login, comprueba si el usuario debe aceptar términos (403 TERMS_NOT_ACCEPTED).
/// Si es así muestra [TermsScreen]; si no, muestra [MainAppShell].
class PostLoginGate extends StatefulWidget {
  const PostLoginGate({
    super.key,
    required this.apis,
    required this.onLogout,
  });

  final AppApis apis;
  final VoidCallback onLogout;

  @override
  State<PostLoginGate> createState() => _PostLoginGateState();
}

class _PostLoginGateState extends State<PostLoginGate> {
  bool? _termsAccepted;
  String? _error;
  bool _accepting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkTerms());
  }

  Future<void> _checkTerms() async {
    setState(() => _error = null);
    try {
      final res = await widget.apis.terms.getActive();
      if (!mounted) return;
      setState(() => _termsAccepted = true);
    } on DioException catch (e) {
      if (!mounted) return;
      if (isTermsNotAccepted(e)) {
        setState(() => _termsAccepted = false);
      } else {
        setState(() {
          _termsAccepted = false;
          _error = apiErrorMessage(e);
        });
      }
    } catch (_) {
      if (mounted) setState(() => _termsAccepted = true);
    }
  }

  Future<void> _acceptTerms() async {
    setState(() => _accepting = true);
    try {
      final res = await widget.apis.terms.accept();
      if (!mounted) return;
      if (res.success) {
        setState(() {
          _termsAccepted = true;
          _accepting = false;
        });
      } else {
        setState(() {
          _error = res.message ?? 'No se pudo aceptar.';
          _accepting = false;
        });
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = apiErrorMessage(e);
        _accepting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_termsAccepted == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Cargando...',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_termsAccepted == false) {
      return TermsScreen(
        onAccept: _acceptTerms,
        loading: _accepting,
        error: _error,
      );
    }

    return MainAppShell(apis: widget.apis, onLogout: widget.onLogout);
  }
}
