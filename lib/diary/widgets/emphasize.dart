import 'package:flutter/material.dart';

class EmphasizeContainer extends StatefulWidget {
  final Widget child;
  final AnimationController controller;
  final double haloSize;
  final Color haloColor;
  final BoxShape shape;

  const EmphasizeContainer({
    super.key,
    required this.child,
    required this.controller,
    required this.haloSize,
    required this.haloColor,
    this.shape = BoxShape.circle,
  });

  // final AnimationController controller;

  @override
  State<StatefulWidget> createState() => _EmphasizeContainerState();
}

class _EmphasizeContainerState extends State<EmphasizeContainer> {
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animation = Tween<double>(begin: 0, end: widget.haloSize).animate(CurvedAnimation(
      parent: widget.controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: widget.shape,
            boxShadow: _animation.value == 0
                ? null
                : [
                    BoxShadow(
                      color: widget.haloColor,
                      spreadRadius: _animation.value,
                    ),
                  ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
