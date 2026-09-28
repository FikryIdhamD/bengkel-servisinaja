import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/segmented_tab_control.dart';
import '../../logic/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  int _activeTabIndex = 0; // 0: OTP, 1: Password
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _countryCode = '+62';

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    if (_activeTabIndex == 0) {
      return _phoneController.text.trim().isNotEmpty;
    } else {
      return _phoneController.text.trim().isNotEmpty &&
          _passwordController.text.isNotEmpty;
    }
  }

  String _normalizePhoneNumber(String rawNumber) {
    String num = rawNumber.replaceAll(RegExp(r'\D'), '');
    if (num.startsWith('0')) {
      num = num.substring(1);
    } else if (_countryCode == '+62' && num.startsWith('62')) {
      num = num.substring(2);
    }
    return '$_countryCode$num';
  }

  Future<void> _handleLogin() async {
    if (!_isFormValid()) return;

    setState(() => _isLoading = true);

    try {
      final phone = _normalizePhoneNumber(_phoneController.text);
      final authRepo = ref.read(authRepositoryProvider);

      if (_activeTabIndex == 0) {
        // Logika Login OTP
        await authRepo.signInWithOtp(phone: phone);
        if (mounted) {
          // TODO: Navigasi ke halaman input OTP (Verifikasi OTP)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kode OTP telah dikirim ke nomor Anda'),
            ),
          );
        }
      } else {
        // Logika Login Password
        await authRepo.signInWithPassword(
          phone: phone,
          password: _passwordController.text,
        );
        if (mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal masuk: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header: Logo Mini & Pengaturan
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          AppAssets.logoMonogram,
                          width: 24,
                          height: 24,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.local_shipping, size: 24),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Servisin Aja',
                        style: AppTypography.headline2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grup Judul Layar
                    Text(
                      'Masuk ke',
                      style: AppTypography.displayTitle.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Akun anda',
                      style: AppTypography.displayTitle.copyWith(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masukkan nomor telepon dan kata sandi anda',
                      style: AppTypography.body2,
                    ),
                    const SizedBox(height: 32),

                    // Dual-Tab Switcher
                    SegmentedTabControl(
                      tabs: const ['Login via OTP', 'Login Password'],
                      selectedIndex: _activeTabIndex,
                      onTabChanged: (index) {
                        setState(() {
                          _activeTabIndex = index;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Input Fields
                    PhoneInputField(
                      controller: _phoneController,
                      onChanged: (_) => setState(() {}),
                      onCountryCodeChanged: (code) {
                        setState(() {
                          _countryCode = code;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    if (_activeTabIndex == 1) ...[
                      CustomTextField(
                        controller: _passwordController,
                        placeholder: 'Masukkan kata sandi',
                        isPassword: true,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 24),

                    // Tombol Submit
                    PrimaryButton(
                      text: 'Masuk',
                      isLoading: _isLoading,
                      onPressed: _isFormValid() ? _handleLogin : null,
                    ),

                    const SizedBox(height: 24),

                    // Tautan Pendaftaran
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // context.push('/register');
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'Belum punya akun? ',
                            style: AppTypography.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: 'Daftar Sekarang',
                                style: AppTypography.body2.copyWith(
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
