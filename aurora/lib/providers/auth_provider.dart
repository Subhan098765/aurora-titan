import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class AuthState {
  final String? token;
  final String? username;
  final String? role;
  final bool isLoading;
  final String? error;

  AuthState({this.token, this.username, this.role, this.isLoading = false, this.error});

  AuthState copyWith({String? token, String? username, String? role, bool? isLoading, String? error}) {
    return AuthState(
      token: token ?? this.token,
      username: username ?? this.username,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState();
  }

  Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(resp) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await http.post(
        Uri.parse('https://aurora-titan-1-896824917672.europe-west1.run.app/api/v1/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': username, 'password': password},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final payload = _decodeJwt(token);
        state = state.copyWith(
          token: token,
          username: payload['sub'] as String?,
          role: payload['role'] as String?,
          isLoading: false,
          error: null,
        );
      } else {
        String errMsg = 'Login Failed';
        try {
          final data = jsonDecode(response.body);
          errMsg = data['detail'] ?? errMsg;
        } catch (_) {}
        state = state.copyWith(isLoading: false, error: errMsg);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Network Error: $e');
    }
  }

  Future<bool> register(String username, String password, String role) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await http.post(
        Uri.parse('https://aurora-titan-1-896824917672.europe-west1.run.app/api/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password, 'role': role}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final payload = _decodeJwt(token);
        state = state.copyWith(
          token: token,
          username: payload['sub'] as String?,
          role: payload['role'] as String?,
          isLoading: false,
          error: null,
        );
        return true;
      } else {
        String errMsg = 'Registration Failed';
        try {
          final data = jsonDecode(response.body);
          errMsg = data['detail'] ?? errMsg;
        } catch (_) {}
        state = state.copyWith(isLoading: false, error: errMsg);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Network Error: $e');
      return false;
    }
  }

  void logout() {
    state = AuthState(token: null);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
