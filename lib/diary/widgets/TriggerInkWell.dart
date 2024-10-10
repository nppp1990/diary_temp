import 'package:flutter/material.dart';

class TriggerInkWell extends StatefulWidget {
  final Widget child;
  final bool showSplash;
  final GestureTapDownCallback? onTapDown;
  final InteractiveInkFeatureFactory? splashFactory;
  final GestureTapCallback? onTap;

  const TriggerInkWell({
    super.key,
    required this.showSplash,
    this.onTap,
    this.onTapDown,
    this.splashFactory,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _TriggerInkWellState();
}

class _TriggerInkWellState extends State<TriggerInkWell> {
  late bool _showSplash;

  @override
  void initState() {
    super.initState();
    _showSplash = widget.showSplash;
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _inkResponseKey.currentState?.startSplash(context);
    //   // _showSplash = false;
    //   // if (_showSplash && widget.onTap != null) {
    //   //   // _triggerItemTap(context);
    //   // }
    // });
    // if (_showSplash && widget.onTap != null) {
    //   Future.delayed(const Duration(milliseconds: 10), () {
    //     if (mounted) {
    //       _triggerItemTap(context);
    //     }
    //   });
    // }
  }

  @override
  void didUpdateWidget(covariant TriggerInkWell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showSplash != oldWidget.showSplash) {
      _showSplash = widget.showSplash;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTapDown: widget.onTapDown,
      splashFactory: widget.splashFactory,
      onTap: widget.onTap == null ? null : _doNothing,
      child: widget.child,
    );
  }

  void _doNothing() {
    // if (!_showSplash) {
    widget.onTap!();
    // }
    // _showSplash = false;
  }

  void _triggerItemTap({
    Duration delay = const Duration(milliseconds: 50),
    Duration touchDuration = const Duration(milliseconds: 1000),
  }) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(const Offset(1, 1));
    Future.delayed(delay, () async {
      if (mounted) {
        return;
      }
      WidgetsBinding.instance.handlePointerEvent(PointerDownEvent(
        pointer: 0,
        position: position,
      ));
      await Future.delayed(touchDuration);
      if (mounted) {
        return;
      }
      WidgetsBinding.instance.handlePointerEvent(PointerUpEvent(
        pointer: 0,
        position: position,
      ));
    });
  }
}
