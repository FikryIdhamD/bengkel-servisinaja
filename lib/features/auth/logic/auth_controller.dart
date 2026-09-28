import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Stream provider to listen to auth state changes
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

// Provider to get the current session synchronously, rebuilds on auth state change
final currentSessionProvider = Provider<Session?>((ref) {
  ref.watch(authStateProvider); // Listen to auth state changes
  return ref.watch(authRepositoryProvider).currentSession;
});
