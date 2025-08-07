import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool hover;

  const CustomCard({
    Key? key,
    required this.child,
    this.margin,
    this.padding,
    this.hover = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: AppTheme.borderRadius,
        border: Border.all(
          color: AppTheme.secondaryColor.withOpacity(0.2),
        ),
        boxShadow: hover ? [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ] : null,
      ),
      child: ClipRRect(
        borderRadius: AppTheme.borderRadius,
        child: Padding(
          padding: padding ?? AppTheme.padding,
          child: child,
        ),
      ),
    );
  }
}
