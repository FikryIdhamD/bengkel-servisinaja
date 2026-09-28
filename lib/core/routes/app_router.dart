import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provide the GoRouter instance via Riverpod so it can react to auth state changes later
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Splash Screen'),
          ), // TODO: Replace with actual Splash Screen
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Login Screen'),
          ), // TODO: Replace with actual Login Screen
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Home Screen'),
          ), // TODO: Replace with actual Home Screen
        ),
      ),
      // Tambahkan route lain sesuai kebutuhan PRD di sini
    ],
    // redirect: (context, state) {
    //   // TODO: Tambahkan logic proteksi rute di sini (cek sesi Supabase)
    //   return null;
    // },
  );
});
