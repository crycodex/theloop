import 'dart:ui';

import 'package:flutter/material.dart';

class OnboardingBackdrop extends StatelessWidget {
  const OnboardingBackdrop({
    super.key,
    required this.child,
    this.alignment = Alignment.center,
    this.showBlurredIcon = true,
    this.iconScale = 1.45,
  });

  final Widget child;
  final Alignment alignment;
  final bool showBlurredIcon;
  final double iconScale;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: Theme.of(context).scaffoldBackgroundColor),
        if (showBlurredIcon)
          Align(
            alignment: alignment,
            child: IgnorePointer(
              child: Opacity(
                opacity: Theme.of(context).brightness == Brightness.dark
                    ? 0.16
                    : 0.34,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                  child: Transform.scale(
                    scale: iconScale,
                    child: Image.asset(
                      'assets/icon/icon.png',
                      width: 330,
                      height: 330,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        child,
      ],
    );
  }
}
