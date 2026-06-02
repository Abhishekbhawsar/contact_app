import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth =
            constraints.maxWidth >= AppConstants.tabletBreakpoint ? 840.0 : double.infinity;
        final horizontalPadding =
            screenWidth < AppConstants.compactBreakpoint ? padding : const EdgeInsets.all(24);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(padding: horizontalPadding, child: child),
          ),
        );
      },
    );
  }
}
