import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_shell.dart';

/// App entry screen. Follows the layout of the login mockup (logo, app
/// name, email, password, primary/secondary/tertiary actions), and now
/// uses the real brand logo (assets/images/logo.png) — the app's navy/blue
/// theme is matched directly to that logo's own colors. There's no backend
/// yet, so "Log In" just moves on to the app — same demo pattern used
/// elsewhere (e.g. "Save as Draft").
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _logIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label (demo — not yet connected to Supabase).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 220,
                      errorBuilder: (context, error, stack) => const _LogoFallback(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Plan sessions. Reflect. Improve.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline_rounded, color: AppColors.textMuted, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 20),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: _logIn,
                    child: const Text('Log In'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _showComingSoon('Create account'),
                    child: const Text('Create Account'),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: TextButton(
                      onPressed: () => _showComingSoon('Password reset'),
                      child: const Text(
                        'Forgotten Password',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fallback shown only if the bundled logo image can't be loaded (e.g. the
/// asset wasn't picked up because of a missed `flutter pub get`), so the
/// login screen still has a mark rather than empty space.
class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentGold, width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.sports_soccer_rounded, color: AppColors.accentGold, size: 38),
          Positioned(
            right: 12,
            bottom: 12,
            child: Icon(Icons.edit_rounded, color: AppColors.textPrimary.withOpacity(0.85), size: 16),
          ),
        ],
      ),
    );
  }
}
