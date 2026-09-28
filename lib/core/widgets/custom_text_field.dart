import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../constants/countries.dart';

class CustomTextField extends StatefulWidget {
  final String placeholder;
  final bool isPassword;
  final TextInputType keyboardType;
  final Widget? prefix;
  final int? minLines;
  final int? maxLines;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    Key? key,
    required this.placeholder,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefix,
    this.minLines,
    this.maxLines = 1,
    this.controller,
    this.onChanged,
    this.inputFormatters,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      inputFormatters: widget.inputFormatters,
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

class PhoneInputField extends StatefulWidget {
  final String placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCountryCodeChanged;

  const PhoneInputField({
    super.key,
    this.placeholder = '82123456789',
    this.controller,
    this.onChanged,
    this.onCountryCodeChanged,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  String _selectedCode = '+62';

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      placeholder: widget.placeholder,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // Mencegah tanda + atau huruf
      ],
      prefix: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCode,
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                isDense: true,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCode = newValue;
                    });
                    if (widget.onCountryCodeChanged != null) {
                      widget.onCountryCodeChanged!(newValue);
                    }
                  }
                },
                items: AppCountries.countryList.map((
                  Map<String, String> country,
                ) {
                  return DropdownMenuItem<String>(
                    value: country['code'],
                    child: Row(
                      children: [
                        Text(
                          country['flag']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          country['code']!,
                          style: AppTypography.body1Medium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 1, height: 24, color: AppColors.border),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
