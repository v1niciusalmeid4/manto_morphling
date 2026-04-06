import 'package:flutter/material.dart';
import 'package:morphling/morphling.dart';

class TotalizatorText<S extends TotalizatorStatus> extends StatelessWidget {
  final S status;
  final bool isNoContent;
  final int quantity;
  final double? total;
  final String? label;
  final Color? labelColor;
  final String? secondLabel;
  final IconData? leadingIcon;

  const TotalizatorText({
    super.key,
    this.quantity = 0,
    this.total,
    this.label,
    this.labelColor,
    this.secondLabel,
    this.leadingIcon,
    this.isNoContent = false,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final Color resolvedLabelColor =
        labelColor ?? Theme.of(context).colorScheme.primary;

    if (status.isEmpty) return const SizedBox.shrink();

    if (status.isLoading) {
      return SkeletonItem(
        width: MediaQuery.sizeOf(context).width * .5,
        height: DesignTokens.sizeXM,
      );
    }

    if (status.isError) {
      return Text(
        isNoContent
            ? 'Não há dados para calcular'
            : 'Falha ao calcular os totalizadores',
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              if (leadingIcon != null) ...[
                Container(
                  width: DesignTokens.sizeXM,
                  height: DesignTokens.sizeXM,
                  decoration: BoxDecoration(
                    color: resolvedLabelColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(DesignTokens.sizeXS),
                    border: Border.all(
                      color: resolvedLabelColor.withValues(alpha: 0.24),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    leadingIcon,
                    size: DesignTokens.sizeSM,
                    color: resolvedLabelColor,
                  ),
                ),
                const SizedBox(width: DesignTokens.sizeXS),
              ],
              Expanded(
                child: Text(
                  label ?? 'TOTAL ($quantity)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: labelColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (total != null || secondLabel != null) ...[
          const SizedBox(width: DesignTokens.sizeXS),
          Text(
            secondLabel ?? '',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
        ],
      ],
    );
  }
}
