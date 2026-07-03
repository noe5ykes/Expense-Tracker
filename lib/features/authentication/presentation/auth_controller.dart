import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

enum AuthStatus { unknown, loggedOut, loggedIn }

@immutable
class AuthState {
  final AuthStatus status;
  final String name;
  final String email;
  final bool hasAccount;
  const AuthState({
    this.status = AuthStatus.unknown,
    this.name = '',
    this.email = '',
    this.hasAccount = false,
  });

  AuthState copyWith(
          {AuthStatus? status, String? name, String? email, bool? hasAccount}) =>
      AuthState(
        status: status ?? this.status,
        name: name ?? this.name,
        email: email ?? this.email,
        hasAccount: hasAccount ?? this.hasAccount,
      );
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

class AuthController extends Notifier<AuthState> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  AuthState build() => const AuthState();

  /// Called once from the splash screen.
  Future<void> restoreSession() async {
    final hasAccount = await _repo.hasAccount();
    final user = await _repo.currentUser();
    state = user == null
        ? AuthState(status: AuthStatus.loggedOut, hasAccount: hasAccount)
        : AuthState(
            status: AuthStatus.loggedIn,
            name: user.name,
            email: user.email,
            hasAccount: true,
          );
  }

  Future<bool> login(String email, String password) async {
    final ok = await _repo.login(email: email, password: password);
    if (ok) await restoreSession();
    return ok;
  }

  Future<void> loginWithBiometrics() async {
    await _repo.loginWithBiometrics();
    await restoreSession();
  }

  Future<void> register(String name, String email, String password) async {
    await _repo.register(name: name, email: email, password: password);
    await restoreSession();
  }

  Future<void> updateProfile(String name) async {
    await _repo.updateProfile(name: name);
    state = state.copyWith(name: name);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = state.copyWith(status: AuthStatus.loggedOut);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
