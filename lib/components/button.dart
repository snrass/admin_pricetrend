import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ButtonVariant { primary, secondary, outline, destructive }

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonVariant variant;
  final bool isLoading;
  final double? width;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: _getBackgroundColor(),
        borderRadius: AppTheme.borderRadius,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppTheme.borderRadius,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: variant == ButtonVariant.outline
                ? Border.all(color: AppTheme.primaryColor)
                : null,
              borderRadius: AppTheme.borderRadius,
            ),
            child: Center(
              child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
                    ),
                  )
                : DefaultTextStyle(
                    style: TextStyle(
                      color: _getTextColor(),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    child: child,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isLoading || onPressed == null) {
      return AppTheme.secondaryColor.withOpacity(0.1);
    }
    switch (variant) {
      case ButtonVariant.primary:
        return AppTheme.primaryColor;
      case ButtonVariant.secondary:
        return AppTheme.secondaryColor.withOpacity(0.1);
      case ButtonVariant.outline:
        return Colors.transparent;
      case ButtonVariant.destructive:
        return AppTheme.errorColor;
    }
  }

  Color _getTextColor() {
    if (isLoading || onPressed == null) {
      return AppTheme.secondaryColor;
    }
    switch (variant) {
      case ButtonVariant.primary:
        return Colors.white;
      case ButtonVariant.secondary:
        return AppTheme.primaryColor;
      case ButtonVariant.outline:
        return AppTheme.primaryColor;
      case ButtonVariant.destructive:
        return Colors.white;
    }
  }
}
