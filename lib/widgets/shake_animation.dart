import 'package:flutter/material.dart';

/// A widget that provides shake animation for invalid input feedback
class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final bool shouldShake;
  final Duration duration;
  final double shakeOffset;

  const ShakeAnimation({
    super.key,
    required this.child,
    this.shouldShake = false,
    this.duration = const Duration(milliseconds: 500),
    this.shakeOffset = 10.0,
  });

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -widget.shakeOffset), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -widget.shakeOffset, end: widget.shakeOffset), weight: 1),
      TweenSequenceItem(tween: Tween(begin: widget.shakeOffset, end: -widget.shakeOffset), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -widget.shakeOffset, end: widget.shakeOffset), weight: 1),
      TweenSequenceItem(tween: Tween(begin: widget.shakeOffset, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(ShakeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldShake && !oldWidget.shouldShake) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: widget.child,
        );
      },
    );
  }
}
