import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Variants for [AppButton].
///
/// - [primary]: Solid primary button with warm terracotta shadow.
/// - [secondary]: Outlined button with surface fill and subtle ambient shadow.
/// - [danger]: Solid crimson button with danger shadow.
/// - [ghost] / [text]: Flat text button without shadow (minimum 48x48 tap target).
enum AppButtonVariant { primary, secondary, danger, ghost, text }

/// Reusable Material 3 button for MIRAIku with:
/// - Centralized [AppShadows] depth (Normal: full shadow, Pressed: smaller shadow
///   + 1.5px downward translation over 120ms, Disabled: no shadow & muted colors)
/// - Guaranteed 48dp minimum tap target
/// - Loading state, optional leading/trailing icon, and custom child support
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final IconData? trailingIcon;
  final Widget? customChild;
  final bool isLoading;
  final bool expand;
  final double height;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.trailingIcon,
    this.customChild,
    this.isLoading = false,
    this.expand = true,
    this.height = 56.0,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  bool get _isTextVariant =>
      widget.variant == AppButtonVariant.ghost ||
      widget.variant == AppButtonVariant.text;

  void _handleHighlightChanged(bool value) {
    if (_isPressed != value) {
      setState(() => _isPressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final effectiveHeight = widget.height < AppSpacing.minTapTarget
        ? AppSpacing.minTapTarget
        : widget.height;
    final double radius = widget.borderRadius ??
        (_isTextVariant ? AppSpacing.radiusMd : AppSpacing.radiusLg);

    final Color primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final Color dangerColor =
        isDark ? AppColors.errorDark : AppColors.errorLight;
    final Color subTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final Color fgColor = _resolveForegroundColor(
      isDark: isDark,
      primaryColor: primaryColor,
      subTextColor: subTextColor,
    );
    final Color bgColor = _resolveBackgroundColor(
      isDark: isDark,
      primaryColor: primaryColor,
      dangerColor: dangerColor,
    );
    final Border? border = _resolveBorder(
      isDark: isDark,
      primaryColor: primaryColor,
    );
    final List<BoxShadow>? boxShadow = _resolveShadows(isDark: isDark);

    Widget childContent;
    if (widget.isLoading) {
      childContent = SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          color: fgColor,
          strokeWidth: 2.5,
        ),
      );
    } else if (widget.customChild != null) {
      childContent = widget.customChild!;
    } else if (widget.icon != null || widget.trailingIcon != null) {
      childContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 18, color: fgColor),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              widget.label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelLarge.copyWith(
                color: fgColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (widget.trailingIcon != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(widget.trailingIcon, size: 18, color: fgColor),
          ],
        ],
      );
    } else {
      childContent = Text(
        widget.label,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.labelLarge.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w800,
        ),
      );
    }

    final Duration animDuration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 120);
    final double pressOffsetY =
        (_isEnabled && !_isTextVariant && _isPressed) ? 1.5 : 0.0;

    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.label,
      child: AnimatedContainer(
        duration: animDuration,
        curve: Curves.easeOutCubic,
        width: widget.expand ? double.infinity : null,
        height: effectiveHeight,
        transform: Matrix4.translationValues(0, pressOffsetY, 0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(radius),
          border: border,
          boxShadow: boxShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: _isEnabled ? widget.onPressed : null,
            onHighlightChanged: _isEnabled ? _handleHighlightChanged : null,
            child: Padding(
              padding: widget.padding ??
                  EdgeInsets.symmetric(
                    horizontal:
                        _isTextVariant ? AppSpacing.lg : AppSpacing.xl,
                  ),
              child: Center(
                widthFactor: widget.expand ? null : 1.0,
                child: childContent,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _resolveBackgroundColor({
    required bool isDark,
    required Color primaryColor,
    required Color dangerColor,
  }) {
    if (_isTextVariant) return Colors.transparent;
    if (!_isEnabled) {
      if (widget.variant == AppButtonVariant.secondary) {
        return Colors.transparent;
      }
      return isDark
          ? AppColors.surfaceVariantDark
          : AppColors.surfaceVariantLight;
    }
    if (widget.backgroundColor != null) return widget.backgroundColor!;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return primaryColor;
      case AppButtonVariant.danger:
        return dangerColor;
      case AppButtonVariant.secondary:
        return isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
      case AppButtonVariant.ghost:
      case AppButtonVariant.text:
        return Colors.transparent;
    }
  }

  Color _resolveForegroundColor({
    required bool isDark,
    required Color primaryColor,
    required Color subTextColor,
  }) {
    if (!_isEnabled) {
      return subTextColor.withValues(alpha: 0.5);
    }
    if (widget.foregroundColor != null) return widget.foregroundColor!;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight;
      case AppButtonVariant.danger:
        return Colors.white;
      case AppButtonVariant.secondary:
        return primaryColor;
      case AppButtonVariant.ghost:
      case AppButtonVariant.text:
        return subTextColor;
    }
  }

  Border? _resolveBorder({
    required bool isDark,
    required Color primaryColor,
  }) {
    if (widget.variant != AppButtonVariant.secondary) return null;
    final Color effectiveBorderColor = !_isEnabled
        ? (isDark ? AppColors.borderDark : AppColors.borderLight)
        : (widget.borderColor ?? primaryColor);
    return Border.all(color: effectiveBorderColor, width: 1.5);
  }

  List<BoxShadow>? _resolveShadows({required bool isDark}) {
    if (!_isEnabled || _isTextVariant) return null;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return _isPressed
            ? AppShadows.buttonPressed(isDark)
            : AppShadows.button(isDark);
      case AppButtonVariant.danger:
        return _isPressed
            ? AppShadows.buttonDangerPressed
            : AppShadows.buttonDanger(isDark);
      case AppButtonVariant.secondary:
        return _isPressed
            ? AppShadows.buttonSecondaryPressed
            : AppShadows.buttonSecondary(isDark);
      case AppButtonVariant.ghost:
      case AppButtonVariant.text:
        return null;
    }
  }
}
