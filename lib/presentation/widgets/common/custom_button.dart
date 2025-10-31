import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

enum ButtonVariant {
  primary,
  secondary,
  outlined,
  text,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final double? width;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate button styling based on variant and size
    final buttonStyle = _getButtonStyle(colorScheme);
    final textStyle = _getTextStyle(theme);
    final padding = _getPadding();
    final height = _getHeight();

    Widget buttonChild = _buildButtonContent(theme);

    if (isLoading) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getContentColor(colorScheme),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSmall),
          Text(
            'Loading...',
            style: textStyle,
          ),
        ],
      );
    }

    Widget button;

    switch (variant) {
      case ButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isDisabled || isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case ButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isDisabled || isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case ButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isDisabled || isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case ButtonVariant.text:
        button = TextButton(
          onPressed: isDisabled || isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
    }

    return SizedBox(
      width: width,
      height: height,
      child: button,
    );
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (icon == null) {
      return Text(
        text,
        style: _getTextStyle(theme),
        textAlign: TextAlign.center,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: _getIconSize(),
          color: _getContentColor(theme.colorScheme),
        ),
        const SizedBox(width: AppTheme.spacingSmall),
        Flexible(
          child: Text(
            text,
            style: _getTextStyle(theme),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  ButtonStyle _getButtonStyle(ColorScheme colorScheme) {
    final baseStyle = ButtonStyle(
      padding: MaterialStateProperty.all(_getPadding()),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
      ),
      elevation: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) return 1;
        if (states.contains(MaterialState.hovered)) return 3;
        return variant == ButtonVariant.primary ? 2 : 0;
      }),
    );

    switch (variant) {
      case ButtonVariant.primary:
        return baseStyle.copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.12);
            }
            if (states.contains(MaterialState.pressed)) {
              return AppTheme.primaryColor.withOpacity(0.8);
            }
            if (states.contains(MaterialState.hovered)) {
              return AppTheme.primaryColor.withOpacity(0.9);
            }
            return AppTheme.primaryColor;
          }),
          foregroundColor: MaterialStateProperty.all(Colors.white),
        );

      case ButtonVariant.secondary:
        return baseStyle.copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.12);
            }
            if (states.contains(MaterialState.pressed)) {
              return AppTheme.secondaryColor.withOpacity(0.8);
            }
            if (states.contains(MaterialState.hovered)) {
              return AppTheme.secondaryColor.withOpacity(0.9);
            }
            return AppTheme.secondaryColor;
          }),
          foregroundColor: MaterialStateProperty.all(Colors.white),
        );

      case ButtonVariant.outlined:
        return baseStyle.copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return AppTheme.primaryColor.withOpacity(0.1);
            }
            if (states.contains(MaterialState.hovered)) {
              return AppTheme.primaryColor.withOpacity(0.05);
            }
            return Colors.transparent;
          }),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.38);
            }
            return AppTheme.primaryColor;
          }),
          side: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return BorderSide(
                color: colorScheme.onSurface.withOpacity(0.12),
                width: 1,
              );
            }
            return const BorderSide(
              color: AppTheme.primaryColor,
              width: 1,
            );
          }),
        );

      case ButtonVariant.text:
        return baseStyle.copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return AppTheme.primaryColor.withOpacity(0.1);
            }
            if (states.contains(MaterialState.hovered)) {
              return AppTheme.primaryColor.withOpacity(0.05);
            }
            return Colors.transparent;
          }),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.38);
            }
            return AppTheme.primaryColor;
          }),
        );
    }
  }

  TextStyle _getTextStyle(ThemeData theme) {
    final baseStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: _getContentColor(theme.colorScheme),
    );

    switch (size) {
      case ButtonSize.small:
        return baseStyle?.copyWith(fontSize: 12) ?? const TextStyle(fontSize: 12);
      case ButtonSize.medium:
        return baseStyle ?? const TextStyle();
      case ButtonSize.large:
        return baseStyle?.copyWith(fontSize: 16) ?? const TextStyle(fontSize: 16);
    }
  }

  Color _getContentColor(ColorScheme colorScheme) {
    if (isDisabled) {
      return colorScheme.onSurface.withOpacity(0.38);
    }

    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
        return Colors.white;
      case ButtonVariant.outlined:
      case ButtonVariant.text:
        return AppTheme.primaryColor;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: AppTheme.spacingSmall,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLarge,
          vertical: AppTheme.spacingMedium,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingXLarge,
          vertical: AppTheme.spacingLarge,
        );
    }
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}