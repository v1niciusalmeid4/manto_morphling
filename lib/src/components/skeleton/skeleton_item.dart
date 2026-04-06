import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonItem extends StatelessWidget {
  final double radius;
  final double? height;
  final double? width;
  final Color? baseColor;
  final Color? highlightColor;
  final Widget? child;

  const SkeletonItem({
    super.key,
    this.height,
    this.width,
    this.radius = 0,
    this.baseColor,
    this.highlightColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        Theme.of(context).brightness == Brightness.light
            ? Colors.grey.shade300
            : Colors.grey.shade400;

    return Shimmer.fromColors(
      baseColor: baseColor ?? color,
      highlightColor: highlightColor ?? Colors.white,
      direction: ShimmerDirection.ltr,
      period: const Duration(milliseconds: 800),
      child:
          child ??
          Material(
            borderRadius: BorderRadius.circular(radius),
            child: SizedBox(
              height: height ?? double.maxFinite,
              width: width ?? double.maxFinite,
            ),
          ),
    );
  }
}
