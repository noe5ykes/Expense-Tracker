import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Local mock authentication backed by the platform keystore/keychain.
/// The interface mirrors what a Firebase/Supabase implementation would need,
/// so swapping in a real backend later is a drop-in change.
class AuthRepository {
  static const _kName = 'auth.name';
  static const _kEmail = 'auth.email';
  static const _kPassword = 'auth.password';
  static const _kLoggedIn = 'auth.loggedIn';

  final FlutterSecureStorage _storage;
  AuthRepository([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  Future<({String name, String email})?> currentUser() async {
    final loggedIn = await _storage.read(key: _kLoggedIn);
    if (loggedIn != 'true') return null;
    final name = await _storage.read(key: _kName) ?? '';
    final email = await _storage.read(key: _kEmail) ?? '';
    return (name: name, email: email);
  }

  Future<bool> hasAccount() async =>
      (await _storage.read(key: _kEmail)) != null;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _storage.write(key: _kName, value: name);
    await _storage.write(key: _kEmail, value: email.trim().toLowerCase());
    await _storage.write(key: _kPassword, value: password);
    await _storage.write(key: _kLoggedIn, value: 'true');
  }

  Future<bool> login({required String email, required String password}) async {
    final storedEmail = await _storage.read(key: _kEmail);
    final storedPassword = await _storage.read(key: _kPassword);
    final ok = storedEmail == email.trim().toLowerCase() &&
        storedPassword == password;
    if (ok) await _storage.write(key: _kLoggedIn, value: 'true');
    return ok;
  }

  /// Re-establishes the session after a successful biometric check.
  Future<void> loginWithBiometrics() =>
      _storage.write(key: _kLoggedIn, value: 'true');

  Future<void> updatePassword(String password) =>
      _storage.write(key: _kPassword, value: password);

  Future<void> updateProfile({required String name}) =>
      _storage.write(key: _kName, value: name);

  Future<void> logout() => _storage.write(key: _kLoggedIn, value: 'false');
}
