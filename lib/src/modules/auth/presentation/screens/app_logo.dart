import 'package:flutter/material.dart';
import 'package:morphling/src/components/layout/design_tokens.dart';

class AppLogo extends StatelessWidget {
  final String appName;
  final String subName;
  final Color? iconColor;
  final Color? titleColor;
  final Color? borderColor;

  const AppLogo({
    super.key,
    this.appName = 'Manto Sistemas',
    this.subName = '',
    this.iconColor,
    this.titleColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/manto.jpg',
          package: 'morphling',
          color: iconColor,
          width: DesignTokens.sizeXXXL,
          height: DesignTokens.sizeXXXL,
        ),
        Material(
          color: Colors.transparent,
          shape: Border(
            left: BorderSide(
              color: borderColor ?? theme.colorScheme.primary,
              width: DesignTokens.sizeXXXXS,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: DesignTokens.sizeXS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text('by Manto Sistemas', style: theme.textTheme.labelLarge),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
