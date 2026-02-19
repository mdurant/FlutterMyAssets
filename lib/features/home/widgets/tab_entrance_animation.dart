import 'package:flutter/material.dart';

/// Envuelve el contenido de una pestaña para animar su entrada: fade-in + slide desde abajo.
/// [delay] retrasa el inicio; [child] es el contenido.
class TabEntranceAnimation extends StatefulWidget {
  const TabEntranceAnimation({
    super.key,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    required this.child,
  });

  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Widget child;

  @override
  State<TabEntranceAnimation> createState() => _TabEntranceAnimationState();
}

class _TabEntranceAnimationState extends State<TabEntranceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _offset = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
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
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _offset.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
