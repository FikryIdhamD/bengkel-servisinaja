import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/logic/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentSessionProvider);
    final user = session?.user;

    // Mengambil data dari metadata saat pendaftaran
    final fullName = user?.userMetadata?['full_name'] ?? 'Tidak ada nama';
    final phone =
        user?.userMetadata?['phone_number'] ?? 'Tidak ada nomor telepon';
    final email = user?.email ?? 'Tidak ada email';
    final token = session?.accessToken ?? 'Tidak ada token';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        title: Text(
          'Beranda (Dummy)',
          style: AppTypography.headline2.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang,',
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                fullName,
                style: AppTypography.headline1.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Kartu Profil
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Detail Profil', style: AppTypography.headline2),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildInfoRow('Email', email),
                    _buildInfoRow('Nomor HP', phone),
                    _buildInfoRow('User ID', user?.id ?? '-'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Kartu Token
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Access Token', style: AppTypography.headline2),
                        IconButton(
                          icon: const Icon(
                            Icons.copy,
                            size: 20,
                            color: AppColors.primaryOrange,
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: token));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Token disalin ke clipboard!'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      token,
                      style: AppTypography.caption.copyWith(
                        fontFamily: 'monospace',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Tombol Keluar
              PrimaryButton(
                text: 'Keluar (Logout)',
                backgroundColor: Colors.red.shade600,
                onPressed: () async {
                  final authRepo = ref.read(authRepositoryProvider);
                  // Pindah halaman dulu agar UI tidak berkedip kosong
                  context.go('/login');
                  // Baru jalankan signout di background
                  Future.microtask(() async {
                    await authRepo.signOut();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body1Medium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
