import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';

class CustomTextField extends StatefulWidget {
  final String placeholder;
  final bool isPassword;
  final TextInputType keyboardType;
  final Widget? prefix;
  final int? minLines;
  final int? maxLines;

  const CustomTextField({
    Key? key,
    required this.placeholder,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefix,
    this.minLines,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      minLines: widget.minLines,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      style: AppTypography.body1Regular,
      decoration: InputDecoration(
        hintText: widget.placeholder,
        prefixIcon: widget.prefix,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }
}

class PhoneInputField extends StatelessWidget {
  final String placeholder;

  const PhoneInputField({
    Key? key,
    this.placeholder = 'Masukkan Nomor Telepon Anda',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      placeholder: placeholder,
      keyboardType: TextInputType.phone,
      prefix: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🇮🇩', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              '+62',
              style: AppTypography.body1Medium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 1, height: 24, color: AppColors.border),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
