import 'package:flutter/material.dart';
import 'package:morphling/morphling.dart';

class ModernTotalizatorCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  final bool showAccentCircle;
  final double minHeight;

  const ModernTotalizatorCard({
    super.key,
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.symmetric(
      horizontal: DesignTokens.sizeSM,
      vertical: DesignTokens.sizeXS,
    ),
    this.showAccentCircle = true,
    this.minHeight = DesignTokens.sizeML,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.sizeSM),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.06),
              blurRadius: DesignTokens.sizeSM,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(DesignTokens.sizeSM),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.surface,
                        colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.75,
                        ),
                      ],
                    ),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.14),
                    ),
                  ),
                ),
              ),
              if (showAccentCircle)
                Positioned(
                  right: -28,
                  top: -28,
                  child: IgnorePointer(
                    child: Container(
                      width: DesignTokens.sizeXL,
                      height: DesignTokens.sizeXL,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class StandardTotalizatorBar extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  final bool showAccentCircle;
  final bool topSafeArea;
  final double minHeight;

  const StandardTotalizatorBar({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.fromLTRB(
      DesignTokens.sizeXS,
      DesignTokens.sizeXXS,
      DesignTokens.sizeXS,
      DesignTokens.sizeXS,
    ),
    this.padding = const EdgeInsets.symmetric(
      horizontal: DesignTokens.sizeSM,
      vertical: DesignTokens.sizeXS,
    ),
    this.showAccentCircle = true,
    this.topSafeArea = false,
    this.minHeight = DesignTokens.sizeML,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: topSafeArea,
      child: ModernTotalizatorCard(
        margin: margin,
        padding: padding,
        showAccentCircle: showAccentCircle,
        minHeight: minHeight,
        child: child,
      ),
    );
  }
}
