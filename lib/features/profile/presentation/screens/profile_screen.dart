import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/logic/auth_controller.dart';
import '../../../../core/widgets/confirmation_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentSessionProvider);
    final user = session?.user;
    final fullName = user?.userMetadata?['full_name'] ?? 'Pengguna';
    final email = user?.email ?? 'Tidak ada email';
    final phone = user?.phone?.isNotEmpty == true
        ? user!.phone!
        : (user?.userMetadata?['phone_number'] ?? 'Belum ditambahkan');
    final isPhoneVerified =
        user?.phone != null &&
        user!
            .phone!
            .isNotEmpty; // simplistic check, ideally use custom claim or profile table

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Profil', style: AppTypography.headline1)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primarySurface,
                  child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                    style: AppTypography.headline1.copyWith(
                      color: AppColors.primaryOrange,
                      fontSize: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: AppTypography.headline1.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(email, style: AppTypography.body2),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Fitur edit profil akan segera hadir',
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          minimumSize: const Size(0, 32),
                          side: const BorderSide(
                            color: AppColors.primaryOrange,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Edit Profil',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Info Details
            _buildProfileSection(
              title: 'Informasi Akun',
              children: [
                _buildProfileItem(
                  icon: Icons.phone,
                  title: 'Nomor Telepon',
                  subtitle: phone,
                  trailing: isPhoneVerified
                      ? const Icon(
                          Icons.verified,
                          color: AppColors.statusSuccess,
                          size: 20,
                        )
                      : TextButton(
                          onPressed: () {
                            // TODO: Implement phone verification logic
                          },
                          child: Text(
                            'Verifikasi',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ),
                ),
                _buildProfileItem(
                  icon: Icons.email,
                  title: 'Email',
                  subtitle: email,
                  trailing: const Icon(
                    Icons.verified,
                    color: AppColors.statusSuccess,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildProfileSection(
              title: 'Lainnya',
              children: [
                _buildProfileItem(
                  icon: Icons.help_outline,
                  title: 'Pusat Bantuan',
                  onTap: () => context.push('/profile/help'),
                ),
                _buildProfileItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Kebijakan Privasi',
                  onTap: () => context.push('/profile/privacy'),
                ),
                _buildProfileItem(
                  icon: Icons.info_outline,
                  title: 'Tentang Servisin Aja',
                  onTap: () => context.push('/profile/about'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return ConfirmationDialog(
                        title: 'Keluar',
                        content: 'Apakah Anda yakin ingin keluar dari akun?',
                        confirmText: 'Keluar',
                        cancelText: 'Batal',
                        onCancel: () => Navigator.pop(dialogContext),
                        onConfirm: () {
                          Navigator.pop(dialogContext); // Tutup dialog
                          final authRepo = ref.read(authRepositoryProvider);
                          context.go('/login'); // Pindah halaman
                          Future.microtask(() async {
                            await authRepo
                                .signOut(); // Proses logout background
                          });
                        },
                      );
                    },
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Keluar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusError,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Versi Aplikasi 1.0.0\n© 2026 Servisin Aja',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.headline2),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryOrange, size: 20),
      ),
      title: Text(title, style: AppTypography.body1Medium),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTypography.body2)
          : null,
      trailing:
          trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: AppColors.border)
              : null),
    );
  }
}
