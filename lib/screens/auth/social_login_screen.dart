import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/session.dart';
import '../../core/ui_helpers.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';

/// A DEMO sign-in page that looks like Google, Apple or Facebook. Nothing is sent
/// anywhere: pick a sample account and the app signs you in as that person.
/// Real social sign-in will be added with Supabase in the final project.
class SocialLoginScreen extends StatefulWidget {
  const SocialLoginScreen({super.key, required this.provider});

  final String provider; // Google, Apple or Facebook

  @override
  State<SocialLoginScreen> createState() => _SocialLoginScreenState();
}

class _SocialLoginScreenState extends State<SocialLoginScreen> {
  static const Color _blue = Color(0xFF1877F2);
  static const Color _googleBlue = Color(0xFF1A73E8);
  static const Color _ink = Color(0xFF202124);
  static const Color _grey = Color(0xFF5F6368);

  late final List<AppUser> _accounts = AppState.instance.users
      .where((u) => u.role == UserRole.passenger && !u.suspended)
      .toList();
  late String _selected = _accounts.isEmpty ? '' : _accounts.first.username;

  String _email(AppUser u) => '${u.username}@demo.example';

  void _signIn(String username) {
    final user = AppState.instance.loginAsDemo(username);
    if (user == null) {
      showMessage(context, 'This demo account is not available', error: true);
      return;
    }
    Session.afterLogin(user);
    showMessage(context, 'Signed in with ${widget.provider} (demo) as ${user.name}.');
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.passenger, (route) => false);
  }

  Widget _banner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFFFF4CE), borderRadius: BorderRadius.circular(10)),
      child: const Text(
        'Demo screen. This is not the real sign-in page. Never type a real password here. '
        'Real sign-in will be added with Supabase.',
        style: TextStyle(color: Color(0xFF5C4500), fontSize: 12),
      ),
    );
  }

  Widget _accountPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBDBDBD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _selected,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: Colors.white,
        style: const TextStyle(color: _ink, fontSize: 15),
        items: [
          for (final u in _accounts) DropdownMenuItem(value: u.username, child: Text('${u.name}  (${_email(u)})')),
        ],
        onChanged: (v) => setState(() => _selected = v ?? _selected),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.provider) {
      case 'Apple':
        return _apple();
      case 'Facebook':
        return _facebook();
      default:
        return _google();
    }
  }

  // ------------------------------------------------------------------ Google
  Widget _google() {
    const letters = [
      ['G', Color(0xFF4285F4)],
      ['o', Color(0xFFEA4335)],
      ['o', Color(0xFFFBBC05)],
      ['g', Color(0xFF4285F4)],
      ['l', Color(0xFF34A853)],
      ['e', Color(0xFFEA4335)],
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _banner(),
            const SizedBox(height: 24),
            Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    for (final l in letters)
                      TextSpan(
                        text: l[0] as String,
                        style: TextStyle(fontSize: 42, fontWeight: FontWeight.w500, color: l[1] as Color),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(child: Text('Choose an account', style: TextStyle(fontSize: 24, color: _ink))),
            const SizedBox(height: 4),
            const Center(
              child: Text('to continue to Salone Transport Hub', style: TextStyle(color: _grey, fontSize: 15)),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            for (var i = 0; i < _accounts.length; i++) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: [const Color(0xFF7B1FA2), const Color(0xFF00897B), const Color(0xFFF4511E)][i % 3],
                  child: Text(_accounts[i].initials, style: const TextStyle(color: Colors.white)),
                ),
                title: Text(_accounts[i].name, style: const TextStyle(color: _ink, fontWeight: FontWeight.w500)),
                subtitle: Text(_email(_accounts[i]), style: const TextStyle(color: _grey)),
                onTap: () => _signIn(_accounts[i].username),
              ),
              const Divider(height: 1),
            ],
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: Color(0xFFE0E0E0), child: Icon(Icons.person_outline, color: _grey)),
              title: Text('Use another account', style: TextStyle(color: _grey)),
              enabled: false,
            ),
            const SizedBox(height: 16),
            const Text(
              'To continue, Google will share your name, email address and profile picture with Salone Transport Hub.',
              style: TextStyle(color: _grey, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 8),
            const Text('Demo only.', style: TextStyle(color: _googleBlue, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------- Apple
  Widget _apple() {
    final account = _accounts.firstWhere((u) => u.username == _selected, orElse: () => _accounts.first);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _banner(),
            const SizedBox(height: 28),
            const Icon(Icons.apple, size: 72, color: Colors.black),
            const SizedBox(height: 12),
            const Text(
              'Sign in with Apple ID',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.black),
            ),
            const SizedBox(height: 6),
            const Text(
              'Use your Apple ID to continue to Salone Transport Hub.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _grey, fontSize: 15),
            ),
            const SizedBox(height: 24),
            const Text('Demo account', style: TextStyle(color: _grey, fontSize: 12)),
            const SizedBox(height: 4),
            _accountPicker(),
            const SizedBox(height: 14),
            TextField(
              key: ValueKey('apple-id-${account.username}'),
              controller: TextEditingController(text: _email(account)),
              readOnly: true,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Apple ID',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: _grey),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: 'demo-password'),
              readOnly: true,
              obscureText: true,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: _grey),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => _signIn(_selected),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 14),
            const Text(
              'Your Apple ID is used only to sign you in. Demo only.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- Facebook
  Widget _facebook() {
    final account = _accounts.firstWhere((u) => u.username == _selected, orElse: () => _accounts.first);
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              color: _blue,
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 28),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    'facebook',
                    style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w800, letterSpacing: -1),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _banner(),
                    const SizedBox(height: 16),
                    const Text(
                      'Log in to Facebook',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _ink),
                    ),
                    const SizedBox(height: 16),
                    const Text('Demo account', style: TextStyle(color: _grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    _accountPicker(),
                    const SizedBox(height: 12),
                    TextField(
                      key: ValueKey('fb-email-${account.username}'),
                      controller: TextEditingController(text: _email(account)),
                      readOnly: true,
                      style: const TextStyle(color: _ink),
                      decoration: const InputDecoration(
                        labelText: 'Email address or phone number',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: _grey),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: TextEditingController(text: 'demo-password'),
                      readOnly: true,
                      obscureText: true,
                      style: const TextStyle(color: _ink),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: _grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _signIn(_selected),
                      style: FilledButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Log In', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Forgotten password?',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _blue, fontWeight: FontWeight.w600),
                    ),
                    const Divider(height: 28),
                    OutlinedButton(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                      child: const Text('Create new account'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
