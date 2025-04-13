import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

enum CustomButtonVariant { primary, secondary, outline, text }

enum CustomButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final CustomButtonSize size;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;
  final bool iconAfterText;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.size = CustomButtonSize.medium,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
    this.iconAfterText = false,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final buttonHeight = _getButtonHeight(size);
    final fontSize = _getFontSize(size);
    final iconSize = _getIconSize(size);

    final buttonStyle = _getButtonStyle(context, isIOS);
    final textStyle = _getTextStyle(context);

    Widget buttonChild = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null && !iconAfterText) ...[
          Icon(icon, size: iconSize),
          SizedBox(width: size == CustomButtonSize.small ? 4 : 8),
        ],
        if (isLoading)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textStyle.color!),
            ),
          )
        else
          Text(text, style: textStyle.copyWith(fontSize: fontSize)),
        if (icon != null && iconAfterText) ...[
          SizedBox(width: size == CustomButtonSize.small ? 4 : 8),
          Icon(icon, size: iconSize),
        ],
      ],
    );

    return SizedBox(
      height: buttonHeight,
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: buttonChild,
      ),
    );
  }

  double _getButtonHeight(CustomButtonSize size) {
    switch (size) {
      case CustomButtonSize.small:
        return 36;
      case CustomButtonSize.medium:
        return 48;
      case CustomButtonSize.large:
        return 56;
    }
  }

  double _getHorizontalPadding(CustomButtonSize size) {
    switch (size) {
      case CustomButtonSize.small:
        return 16;
      case CustomButtonSize.medium:
        return 24;
      case CustomButtonSize.large:
        return 32;
    }
  }

  double _getFontSize(CustomButtonSize size) {
    switch (size) {
      case CustomButtonSize.small:
        return 14;
      case CustomButtonSize.medium:
        return 16;
      case CustomButtonSize.large:
        return 18;
    }
  }

  double _getIconSize(CustomButtonSize size) {
    switch (size) {
      case CustomButtonSize.small:
        return 16;
      case CustomButtonSize.medium:
        return 20;
      case CustomButtonSize.large:
        return 24;
    }
  }

  ButtonStyle _getButtonStyle(BuildContext context, bool isIOS) {
    final radius = isIOS ? 12.0 : 8.0;
    final horizontalPadding = _getHorizontalPadding(size);

    switch (variant) {
      case CustomButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: isIOS ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        );

      case CustomButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          elevation: isIOS ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        );

      case CustomButtonVariant.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(color: AppColors.primary),
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        );

      case CustomButtonVariant.text:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        );
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    switch (variant) {
      case CustomButtonVariant.primary:
      case CustomButtonVariant.secondary:
        return AppTheme.bodyStyle.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        );
      case CustomButtonVariant.outline:
      case CustomButtonVariant.text:
        return AppTheme.bodyStyle.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        );
    }
  }
}
