import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onGetStarted});

  final VoidCallback onGetStarted;

  static const _steps = ['Design', 'Build', 'Customize', 'Collaborate', 'Test', 'Deploy'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              ..._steps.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    e,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ) ?? TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'you build',
                style: textTheme.headlineLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ) ?? const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'FlutterMyAssets es la plataforma para buscar y publicar propiedades. Regístrate y comienza a explorar.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  height: 1.5,
                ) ?? const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: 'Comenzar gratis',
                  onPressed: onGetStarted,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Design stunning apps scale as you grow',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ) ?? const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
