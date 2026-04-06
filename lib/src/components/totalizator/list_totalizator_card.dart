import 'package:flutter/material.dart';
import 'package:morphling/morphling.dart';

class ListTotalizatorCard extends StatelessWidget {
  final Widget child;

  const ListTotalizatorCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StandardTotalizatorBar(child: child);
  }
}
