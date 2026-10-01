import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/app_notification.dart';
import '../../logic/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String _countryCode = '+62';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _nameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _passwordController.text == _confirmController.text;
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

  Future<void> _handleRegister() async {
    if (!_isFormValid()) return;

    setState(() => _isLoading = true);

    try {
      final phone = _normalizePhoneNumber(_phoneController.text);
      final authRepo = ref.read(authRepositoryProvider);

      await authRepo.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        phone: phone,
      );

      if (mounted) {
        _showEmailVerificationModal();
      }
    } catch (e) {
      if (mounted) {
        AppNotification.showError(
          context,
          'Gagal mendaftar: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showEmailVerificationModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_rounded,
                    size: 80,
                    color: AppColors.primaryOrange,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Verifikasi Email Anda',
                  style: AppTypography.headline1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Tautan verifikasi telah dikirimkan ke email:\n${_emailController.text}\n\nSilakan cek kotak masuk Anda sebelum masuk ke aplikasi.',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'Kembali ke Login',
                  onPressed: () {
                    // Tutup modal lalu arahkan ke halaman login
                    Navigator.of(context).pop();
                    context.go('/login');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Daftar Akun Baru',
          style: AppTypography.headline2.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lengkapi profil Anda untuk mulai menikmati kemudahan servis motor dari mana saja.',
                style: AppTypography.body2,
              ),
              const SizedBox(height: 24),

              // Form Nama
              CustomTextField(
                controller: _nameController,
                placeholder: 'Nama Lengkap',
                prefix: const Icon(
                  Icons.person_outline,
                  color: AppColors.textSecondary,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Form Nomor Telepon
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

              // Form Email
              CustomTextField(
                controller: _emailController,
                placeholder: 'Alamat Email',
                keyboardType: TextInputType.emailAddress,
                prefix: const Icon(
                  Icons.email_outlined,
                  color: AppColors.textSecondary,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Form Kata Sandi
              CustomTextField(
                controller: _passwordController,
                placeholder: 'Kata Sandi (Minimal 6 karakter)',
                isPassword: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Form Konfirmasi Kata Sandi
              CustomTextField(
                controller: _confirmController,
                placeholder: 'Konfirmasi Kata Sandi',
                isPassword: true,
                onChanged: (_) => setState(() {}),
              ),

              // Helper text untuk password mismatch
              if (_passwordController.text.isNotEmpty &&
                  _confirmController.text.isNotEmpty &&
                  _passwordController.text != _confirmController.text)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                  child: Text(
                    'Kata sandi tidak cocok',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.statusError,
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Tombol Submit
              PrimaryButton(
                text: 'Daftar Sekarang',
                isLoading: _isLoading,
                onPressed: _isFormValid() ? _handleRegister : null,
              ),

              const SizedBox(height: 24),

              // Tautan Login
              Center(
                child: GestureDetector(
                  onTap: () =>
                      context.pop(), // Kembali ke halaman login sebelumnya
                  child: RichText(
                    text: TextSpan(
                      text: 'Sudah punya akun? ',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: 'Masuk Sekarang',
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
