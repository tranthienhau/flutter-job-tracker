import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/job.dart';

class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;

  AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = true,
  });

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final box = Hive.box('auth');
      final stored = box.get('user');
      if (stored != null) {
        final user = User.fromJson(
          Map<String, dynamic>.from(jsonDecode(stored as String)),
        );
        state = AuthState(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = AuthState(isLoading: false);
      }
    } catch (_) {
      state = AuthState(isLoading: false);
    }
  }

  Future<void> login(String email, String password) async {
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: email.split('@')[0],
      trade: 'General Maintenance',
    );
    final box = Hive.box('auth');
    await box.put('user', jsonEncode(user.toJson()));
    state = AuthState(
      user: user,
      isAuthenticated: true,
      isLoading: false,
    );
  }

  Future<void> register(
    String name,
    String email,
    String password, {
    String? trade,
  }) async {
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      trade: trade ?? 'General Maintenance',
    );
    final box = Hive.box('auth');
    await box.put('user', jsonEncode(user.toJson()));
    state = AuthState(
      user: user,
      isAuthenticated: true,
      isLoading: false,
    );
  }

  Future<void> logout() async {
    final box = Hive.box('auth');
    await box.delete('user');
    state = AuthState(
      user: null,
      isAuthenticated: false,
      isLoading: false,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
