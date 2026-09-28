import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_config.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client})
    : _client = client ?? SupabaseConfig.client;

  // Stream of auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Current session
  Session? get currentSession => _client.auth.currentSession;

  // Sign up
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'phone_number': phone},
    );
  }

  // Sign in with password
  Future<AuthResponse> signInWithPassword({
    String? email,
    String? phone,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      phone: phone,
      password: password,
    );
  }

  // Sign in with OTP
  Future<void> signInWithOtp({required String phone}) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  // Verify OTP
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) async {
    return await _client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
