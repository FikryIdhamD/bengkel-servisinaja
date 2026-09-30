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
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'phone_number': phone},
    );

    final userId = response.user?.id;
    if (userId != null && response.session != null) {
      try {
        final existing = await _client
            .from('vehicles')
            .select('id')
            .eq('user_id', userId);
        if ((existing as List).isEmpty) {
          await _client.from('vehicles').insert([
            {
              'user_id': userId,
              'plate_number': 'B 1234 PSA',
              'model_name': 'Honda Vario 160',
              'year': 2023,
            },
            {
              'user_id': userId,
              'plate_number': 'B 5678 PSA',
              'model_name': 'Honda BeAT FI',
              'year': 2022,
            },
          ]);
        }
      } catch (_) {
        // Handled by database trigger handle_new_user or on first login
      }
    }

    return response;
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
