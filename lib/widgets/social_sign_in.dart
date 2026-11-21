import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_routes.dart';

/// "Or continue with" row with Google, Apple and Facebook buttons. Each opens a
/// demo sign-in page that looks like that provider. These are DEMOS: real sign-in
/// will be added with Supabase in the final project.
class SocialSignInRow extends StatelessWidget {
  const SocialSignInRow({super.key, this.heading = 'Or continue with'});

  final String heading;

  void _open(BuildContext context, String provider) {
    Navigator.pushNamed(context, AppRoutes.socialLogin, arguments: provider);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(heading, style: TextStyle(color: AppColors.textSecondary)),
            ),
            Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                label: 'Google',
                onTap: () => _open(context, 'Google'),
                child: const Text(
                  'G',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF4285F4)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SocialButton(
                label: 'Apple',
                onTap: () => _open(context, 'Apple'),
                child: Icon(Icons.apple, size: 28, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SocialButton(
                label: 'Facebook',
                onTap: () => _open(context, 'Facebook'),
                child: const Icon(Icons.facebook, size: 28, color: Color(0xFF1877F2)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.child, required this.onTap});

  final String label;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: AppColors.surface,
        side: BorderSide(color: AppColors.border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Semantics(label: 'Continue with $label', child: child),
    );
  }
}
