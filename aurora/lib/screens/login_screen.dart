import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/aurora_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  String _selectedRole = 'commander';

  void _submit() {
    final u = _usernameController.text.trim();
    final p = _passwordController.text.trim();
    if (u.isNotEmpty && p.isNotEmpty) {
      if (_isLogin) {
        ref.read(authProvider.notifier).login(u, p);
      } else {
        ref.read(authProvider.notifier).register(u, p, _selectedRole);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AuroraTheme.background,
      body: Stack(
        children: [
          // Background graphic
          Center(
            child: Icon(Icons.public, size: 400, color: AuroraTheme.primaryNeon.withValues(alpha: 0.05)),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AuroraTheme.surface.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AuroraTheme.primaryNeon.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.security, size: 64, color: AuroraTheme.primaryNeon),
                          const SizedBox(height: 16),
                          Text(
                            _isLogin ? 'AURORA AUTHORIZATION' : 'AURORA REGISTRATION',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 32),
                          if (authState.error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                authState.error!,
                                style: const TextStyle(color: AuroraTheme.warning, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          TextField(
                            controller: _usernameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Username',
                              labelStyle: const TextStyle(color: AuroraTheme.textMuted),
                              enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AuroraTheme.primaryNeon)),
                              prefixIcon: const Icon(Icons.person, color: AuroraTheme.textMuted),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Passcode',
                              labelStyle: const TextStyle(color: AuroraTheme.textMuted),
                              enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AuroraTheme.primaryNeon)),
                              prefixIcon: const Icon(Icons.lock, color: AuroraTheme.textMuted),
                            ),
                          ),
                          if (!_isLogin) ...[
                            const SizedBox(height: 16),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text('OPERATIONAL ROLE', style: TextStyle(color: AuroraTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedRole = 'commander'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _selectedRole == 'commander'
                                            ? AuroraTheme.primaryNeon.withValues(alpha: 0.15)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: _selectedRole == 'commander'
                                              ? AuroraTheme.primaryNeon
                                              : Colors.white24,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Commander',
                                          style: TextStyle(
                                            color: _selectedRole == 'commander'
                                                ? AuroraTheme.primaryNeon
                                                : Colors.white54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedRole = 'agent'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _selectedRole == 'agent'
                                            ? AuroraTheme.secondaryNeon.withValues(alpha: 0.15)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: _selectedRole == 'agent'
                                              ? AuroraTheme.secondaryNeon
                                              : Colors.white24,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Field Agent',
                                          style: TextStyle(
                                            color: _selectedRole == 'agent'
                                                ? AuroraTheme.secondaryNeon
                                                : Colors.white54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: authState.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AuroraTheme.primaryNeon,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: authState.isLoading
                                  ? const CircularProgressIndicator(color: Colors.black)
                                  : Text(
                                      _isLogin ? 'AUTHENTICATE' : 'REGISTER CREDENTIALS',
                                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin
                                  ? 'REQUEST NEW OPERATOR ACCESS'
                                  : 'EXISTING OPERATOR SIGN IN',
                              style: const TextStyle(
                                color: AuroraTheme.primaryNeon,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
