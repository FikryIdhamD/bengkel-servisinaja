import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/garage/presentation/screens/garage_screen.dart';
import '../../features/home/presentation/screens/main_layout_screen.dart';
import '../../features/booking/presentation/screens/workshop_selection_screen.dart';
import '../../features/booking/presentation/screens/vehicle_selection_screen.dart';
import '../../features/booking/presentation/screens/service_configuration_screen.dart';
import '../../features/booking/presentation/screens/schedule_workshop_screen.dart';
import '../../features/booking/presentation/screens/summary_checkout_screen.dart';
import '../../features/tracking/presentation/screens/booking_ticket_tracking_screen.dart';
import '../../features/tracking/presentation/screens/ticket_list_screen.dart';

// Provide the GoRouter instance via Riverpod so it can react to auth state changes later
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayoutScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/garage',
            builder: (context, state) => const GarageScreen(),
          ),
          GoRoute(
            path: '/tickets',
            builder: (context, state) => const TicketListScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Halaman Profil (Tahap Pengembangan)')),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/workshop-selection',
        builder: (context, state) => const WorkshopSelectionScreen(),
      ),
      GoRoute(
        path: '/vehicle-selection',
        builder: (context, state) => const VehicleSelectionScreen(),
      ),
      GoRoute(
        path: '/service-configuration',
        builder: (context, state) => const ServiceConfigurationScreen(),
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const ScheduleWorkshopScreen(),
      ),
      GoRoute(
        path: '/summary-checkout',
        builder: (context, state) => const SummaryCheckoutScreen(),
      ),
      GoRoute(
        path: '/tracking/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BookingTicketTrackingScreen(bookingId: id);
        },
      ),
    ],
  );
});
