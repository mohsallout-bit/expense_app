import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextStyle? style;
  final bool isDense;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final bool readOnly;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.validator,
    this.style,
    this.isDense = false,
    this.inputFormatters,
    this.autofocus = false,
    this.focusNode,
    this.onTap,
    this.onChanged,
    this.readOnly = false,
    this.maxLines = 1,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final density = isDense ? 12.0 : 16.0;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            prefixIcon != null
                ? Icon(
                  prefixIcon,
                  color: AppColors.primary.withOpacity(0.7),
                  size: isDense ? 20 : 24,
                )
                : null,
        suffix: suffix,
        contentPadding: EdgeInsets.symmetric(
          horizontal: density * 1.25,
          vertical: density,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
          borderSide: BorderSide(color: AppColors.error.withOpacity(0.8)),
        ),
        filled: true,
        fillColor: isIOS ? Colors.grey.shade50 : Colors.white,
      ),
      style:
          style ??
          Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(height: isIOS ? 1.3 : 1.2),
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      autofocus: autofocus,
      focusNode: focusNode,
      onTap: onTap,
      onChanged: onChanged,
      readOnly: readOnly,
      maxLines: maxLines,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
    );
  }
}
