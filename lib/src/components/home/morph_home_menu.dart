import 'package:flutter/material.dart';
import 'package:morphling/src/components/layout/design_tokens.dart';

class MorphHomeMenuAction {
  const MorphHomeMenuAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconWidget,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Widget? iconWidget;
}

class MorphHomeMenu extends StatelessWidget {
  const MorphHomeMenu({
    super.key,
    this.userName,
    required this.actions,
    this.tooltip = 'Menu',
    this.headerSubtitle = 'Menu rapido da home',
    this.emptyUserLabel = 'Usuario',
    this.icon,
    this.shapeBorderWidth = DesignTokens.borderWidth,
  });

  final String? userName;
  final List<MorphHomeMenuAction> actions;
  final String tooltip;
  final String headerSubtitle;
  final String emptyUserLabel;
  final Widget? icon;
  final double shapeBorderWidth;

  String get _normalizedUserName => (userName ?? '').trim();

  String get _firstName {
    if (_normalizedUserName.isEmpty) return emptyUserLabel;

    final first = _normalizedUserName.split(' ').first.trim();
    if (first.isEmpty) return emptyUserLabel;

    return first[0].toUpperCase() + first.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor =
        theme.brightness == Brightness.light
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface;

    return PopupMenuButton<int>(
      elevation: 0,
      tooltip: tooltip,
      color: theme.colorScheme.surface,
      shadowColor: Colors.black26,
      surfaceTintColor: Colors.transparent,
      icon: icon ?? const Icon(Icons.menu_rounded),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.sizeM),
        side: BorderSide(color: theme.dividerColor, width: shapeBorderWidth),
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem<int>(
            enabled: false,
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.sizeXS,
              DesignTokens.sizeXS,
              DesignTokens.sizeXS,
              DesignTokens.sizeXXS,
            ),
            child: _MorphHomeMenuHeader(
              firstName: _firstName,
              subtitle: headerSubtitle,
            ),
          ),
          const PopupMenuDivider(height: 1),
          ...List.generate(actions.length, (index) {
            final action = actions[index];
            return PopupMenuItem<int>(
              value: index,
              onTap: () => Future.delayed(Duration.zero, action.onTap),
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.sizeXS,
                vertical: DesignTokens.sizeXXXS,
              ),
              child: _MorphHomeMenuTile(
                action: action,
                iconColor: iconColor,
                iconWidget: action.iconWidget,
              ),
            );
          }),
        ];
      },
    );
  }
}

class _MorphHomeMenuHeader extends StatelessWidget {
  const _MorphHomeMenuHeader({required this.firstName, required this.subtitle});

  final String firstName;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.sizeM),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F62D8), Color(0xFF1495FF)],
        ),
      ),
      padding: const EdgeInsets.all(DesignTokens.sizeXS),
      child: Row(
        children: [
          Container(
            width: DesignTokens.sizeXXM,
            height: DesignTokens.sizeXXM,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x26FFFFFF),
            ),
            alignment: Alignment.center,
            child: Text(
              firstName[0],
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.sizeXS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firstName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: DesignTokens.sizeXXXXS),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MorphHomeMenuTile extends StatelessWidget {
  const _MorphHomeMenuTile({
    required this.action,
    required this.iconColor,
    this.iconWidget,
  });

  final MorphHomeMenuAction action;
  final Color iconColor;
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveIconColor = action.iconColor ?? iconColor;

    return Row(
      children: [
        Container(
          width: DesignTokens.sizeXXM,
          height: DesignTokens.sizeXXM,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.sizeXS),
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
          ),
          child:
              action.iconWidget ?? Icon(action.icon, color: effectiveIconColor),
        ),
        const SizedBox(width: DesignTokens.sizeXS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                action.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: DesignTokens.sizeXXXXS),
              Text(
                action.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: theme.hintColor),
      ],
    );
  }
}
