import 'package:flutter/material.dart';

class IslamicBackground extends StatelessWidget {
  final Widget child;

  const IslamicBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        image: DecorationImage(
          image: AssetImage('assets/patterns/islamic_pattern.png'),
          opacity: 0.03,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: child,
    );
  }
}
