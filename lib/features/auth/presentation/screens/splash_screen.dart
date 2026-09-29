import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../logic/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Memberikan durasi tayang sesuai Design.md (1.5 detik)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Mengecek apakah ada sesi aktif di Supabase
    final session = ref.read(currentSessionProvider);

    if (session != null) {
      // Jika sesi ada (pengguna sudah login)
      context.go('/home');
    } else {
      // Jika sesi kosong (pengguna belum login / belum terverifikasi)
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Monogram
                    const AppLogo(size: 100),
                    const SizedBox(height: 16),
                    // Teks Merek
                    Text(
                      'PitStop',
                      style: AppTypography.displayTitle.copyWith(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Slogan / Tagline
                    Text.rich(
                      TextSpan(
                        text: 'By ',
                        style: AppTypography.body2.copyWith(
                          fontSize: 12,
                          color: AppColors.charcoalDark,
                        ),
                        children: [
                          TextSpan(
                            text: 'Servisin Aja',
                            style: TextStyle(
                              color: AppColors
                                  .primaryOrange, // Otomatis mengikuti ukuran 12 dan body2 dari atas
                            ),
                          ),
                        ],
                      ),
                    ),
                  ], // Penutup children Column dalam yang benar
                ), // Penutup Column dalam yang benar
              ),
            ),
            // Zona Dasar Layar (Footer)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                '© 2026 Servisin Aja. All rights reserved.',
                style: AppTypography.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
