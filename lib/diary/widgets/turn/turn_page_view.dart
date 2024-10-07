import 'package:dribbble/diary/widgets/turn/const.dart';
import 'package:dribbble/diary/widgets/turn/turn_direction.dart';
import 'package:dribbble/diary/widgets/turn/turn_page_animation.dart';
import 'package:flutter/material.dart';

final _defaultPageController = TurnPageController(initialPage: 0);
const _defaultThresholdValue = 0.3;

/// The [TurnPageView] class is a widget likes [PageView] with a custom page transition animation.
class TurnPageView extends StatefulWidget {
  /// Creates a new pageable view with a turning page effect using the provided itemBuilder.
  /// The [itemCount] and [itemBuilder] parameters must not be null.
  TurnPageView.builder({
    super.key,
    TurnPageController? controller,
    required this.itemCount,
    required this.itemBuilder,
    this.overleafColorBuilder,
    this.animationTransitionPoint = defaultAnimationTransitionPoint,
    this.useOnTap = true,
    this.useOnSwipe = true,
  })  : assert(itemCount > 0),
        assert(0 <= animationTransitionPoint && animationTransitionPoint < 1),
        controller = controller ?? _defaultPageController;

  /// The controller used to interact with the TurnPageView.
  final TurnPageController controller;

  /// The total number of pages in the TurnPageView.
  final int itemCount;

  /// A builder function that returns the widget for each page.
  final IndexedWidgetBuilder itemBuilder;

  /// A builder function that returns the overleaf color for each page.
  final Color Function(int index)? overleafColorBuilder;

  /// The point that behavior of the turn-page-animation changes.
  /// This value must be 0 <= animationTransitionPoint < 1.
  final double animationTransitionPoint;

  /// Determines whether the TurnPageView should respond to tap events to change pages.
  final bool useOnTap;

  /// Determines whether the TurnPageView should respond to swipe events to change pages.
  final bool useOnSwipe;

  @override
  State<TurnPageView> createState() => _TurnPageViewState();
}

class _TurnPageViewState extends State<TurnPageView> with TickerProviderStateMixin {
  late final List<Widget> pages;


  @override
  void initState() {
    super.initState();
    widget.controller._animation = TurnAnimationController(
      vsync: this,
      initialPage: widget.controller.initialPage,
      itemCount: widget.itemCount,
      thresholdValue: widget.controller.thresholdValue,
      duration: widget.controller.duration,
      onPageChanged: widget.controller.onPageChanged,
    );

    pages = List.generate(
      widget.itemCount,
      (index) {
        final pageIndex = (widget.itemCount - 1) - index;
        final animation = widget.controller._animation._controllers[pageIndex];
        final page = widget.itemBuilder(context, pageIndex);

        return ValueListenableBuilder<bool>(
          valueListenable: widget.controller._animation.visibleNotifierList[pageIndex],
          builder: (context, value, child) => Visibility(
            visible: value,
            child: AnimatedBuilder(
              animation: animation,
              child: page,
              builder: (context, child) => TurnPageAnimation(
                index: pageIndex,
                animation: animation,
                overleafColor: widget.overleafColorBuilder?.call(pageIndex) ?? defaultOverleafColor,
                animationTransitionPoint: widget.animationTransitionPoint,
                direction: widget.controller.direction,
                cornerRadius: widget.controller.cornerRadius,
                child: child ?? page,
              ),
            ),
          ),
          // child: AnimatedBuilder(
          //   animation: animation,
          //   child: page,
          //   builder: (context, child) => TurnPageAnimation(
          //     index: pageIndex,
          //     animation: animation,
          //     // overleafColor指的是翻页时背面的颜色
          //     overleafColor: widget.overleafColorBuilder?.call(pageIndex) ?? defaultOverleafColor,
          //     // animationTransitionPoint指的是翻页动画的变化点
          //     animationTransitionPoint: widget.animationTransitionPoint,
          //     direction: widget.controller.direction,
          //     cornerRadius: widget.controller.cornerRadius,
          //     child: child ?? page,
          //   ),
          // ),
        );
      },
    );

    // test
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        widget.controller.animateToPage(1);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        onTapUp: (details) async {
          if (!widget.useOnTap) {
            return;
          }
          print('-----onTapUp: $details');
          controller._onTapUp(
            details: details,
            constraints: constraints,
          );
        },

        // onVerticalDragUpdate: (details) {
        //   print('-----onVerticalDragUpdate: $details');
        //   // if (!widget.useOnSwipe) {
        //   //   return;
        //   // }
        //   // controller._onHorizontalDragUpdate(
        //   //   details: details,
        //   //   constraints: constraints,
        //   // );
        //
        // },

        onHorizontalDragUpdate: (details) {
          // print('-----onHorizontalDragUpdate: $details, useOnSwipe: ${widget.useOnSwipe}');
          if (!widget.useOnSwipe) {
            return;
          }
          controller._onHorizontalDragUpdate(
            details: details,
            constraints: constraints,
          );
        },
        onHorizontalDragEnd: (_) {
          if (!widget.useOnSwipe) {
            return;
          }
          controller._onHorizontalDragEnd();
        },
        child: Stack(
          children: pages,
        ),
      ),
    );
  }
}

/// [TurnPageController] is responsible for managing the page state
/// and controlling the page-turning animation for [TurnPageView].
class TurnPageController extends ChangeNotifier {
  final int initialPage;

  /// The direction in which the pages are turned.
  final TurnDirection direction;

  /// The threshold value is used to determine whether a page turn should be
  /// completed or reverted based on the percentage of the swipe gesture.
  final double thresholdValue;

  /// The duration during which the page is turned.
  final Duration duration;

  final double cornerRadius;

  final ValueChanged<int>? onPageChanged;

  TurnPageController({
    this.initialPage = 0,
    this.direction = TurnDirection.rightToLeft,
    this.thresholdValue = _defaultThresholdValue,
    this.duration = defaultTransitionDuration,
    this.cornerRadius = 0,
    this.onPageChanged,
  }) : assert(0 <= thresholdValue && thresholdValue <= 1);

  late TurnAnimationController _animation;

  bool? _isTurnForward;

  int get currentIndex => _animation.currentIndex;

  int get itemCount => _animation.itemCount;

  @override
  void dispose() {
    print('-----TurnPageController dispose');
    _animation.dispose();
    super.dispose();
  }

  /// Moves to the next page in the view.
  void nextPage() => _animation.turnNextPage();

  /// Moves to the previous page in the view.
  void previousPage() => _animation.turnPreviousPage();

  /// Animate to a specific page in the view.
  Future<void> animateToPage(int index) async {
    final diff = index - _animation.currentIndex;
    for (var i = 0; i < diff.abs(); i++) {
      diff >= 0 ? _animation.turnNextPage() : _animation.turnPreviousPage();
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  /// Moves to a specific page in the view.
  void jumpToPage(int index) => _animation.jump(index);

  void _onTapUp({
    required TapUpDetails details,
    required BoxConstraints constraints,
  }) {
    final isLeftSideTapped = details.localPosition.dx <= constraints.maxWidth / 2;

    switch (direction) {
      case TurnDirection.rightToLeft:
        isLeftSideTapped ? previousPage() : nextPage();
        break;
      case TurnDirection.leftToRight:
        isLeftSideTapped ? nextPage() : previousPage();
        break;
    }
  }

  void _onHorizontalDragUpdate({
    required DragUpdateDetails details,
    required BoxConstraints constraints,
  }) {
    final width = constraints.maxWidth;
    late final double delta;
    switch (direction) {
      case TurnDirection.rightToLeft:
        delta = -(details.primaryDelta ?? 0) / width;
        break;
      case TurnDirection.leftToRight:
        delta = (details.primaryDelta ?? 0) / width;
        break;
    }

    if (this._isTurnForward == null) {
      this._isTurnForward = delta >= 0;
    }
    final isTurnForward = this._isTurnForward != null ? this._isTurnForward! : delta >= 0;

    if (isTurnForward) {
      final currentPageController = _animation.currentPage;
      if (currentPageController == null) {
        return;
      }
      var updated = currentPageController.value + delta;
      if (updated <= 0.0) {
        updated = 0.0;
      } else if (updated >= 1.0) {
        updated = 1.0;
      }
      // print('-----updated: $updated');
      _animation.updateCurrentPage(updated);
      notifyListeners();
    } else {
      final previousPageController = _animation.previousPage;
      if (previousPageController == null) {
        return;
      }
      var updated = previousPageController.value + delta;
      if (updated <= 0.0) {
        updated = 0.0;
      } else if (updated >= 1.0) {
        updated = 1.0;
      }
      // print('-----updatePreviousPage: $updated');
      _animation.updatePreviousPage(updated);
      notifyListeners();
    }
  }

  void _onHorizontalDragEnd() {
    if (!_animation.thresholdExceeded) {
      _animation.reverse();
    } else {
      if (_isTurnForward == true) {
        nextPage();
      }
      if (_isTurnForward == false) {
        previousPage();
      }
    }
    _isTurnForward = null;
  }
}

const _animationMinValue = 0.0;
const _animationMaxValue = 1.0;

/// [TurnAnimationController] is responsible for managing the animation
/// of the [TurnPageView] widget.
class TurnAnimationController {
  /// The index of the first page to display
  final int initialPage;

  /// The total number of pages in the TurnPageView.
  final int itemCount;

  /// The threshold value is used to determine whether a page turn should be
  /// completed or reverted based on the percentage of the swipe gesture.
  final double thresholdValue;

  /// The duration during which the page is turned.
  final Duration duration;

  final List<AnimationController> _controllers;

  final List<ValueNotifier<bool>> visibleNotifierList;

  final ValueChanged<int>? onPageChanged;

  int currentIndex;

  TurnAnimationController({
    required TickerProvider vsync,
    required this.initialPage,
    required this.itemCount,
    required this.thresholdValue,
    required this.duration,
    int preShowPageCount = 2,
    this.onPageChanged,
  })  : currentIndex = 0,
        _controllers = List.generate(
          itemCount,
          (index) => AnimationController(
            vsync: vsync,
            duration: duration,
            value: index < initialPage ? _animationMaxValue : _animationMinValue,
          ),
        ),
        visibleNotifierList = List.generate(
          itemCount,
          (index) => ValueNotifier<bool>(index >= initialPage - 1 && index < initialPage + preShowPageCount),
        );

  AnimationController? get previousPage => currentIndex > 0 ? _controllers[currentIndex - 1] : null;

  AnimationController? get currentPage => currentIndex < itemCount - 1 ? _controllers[currentIndex] : null;

  bool get thresholdExceeded {
    final currentPage = this.currentPage;
    final previousPage = this.previousPage;
    return currentPage != null && currentPage.value >= thresholdValue ||
        previousPage != null && previousPage.value < (1 - thresholdValue);
  }

  bool get isNextPageNone => currentIndex + 1 >= itemCount;

  bool get isPreviousPageNone => currentIndex - 1 < 0;

  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final notifier in visibleNotifierList) {
      notifier.dispose();
    }
  }

  Future<void> reverse() async {
    if (previousPage?.value != _animationMaxValue) {
      await previousPage?.animateTo(_animationMaxValue);
    }
    if (currentPage?.value != _animationMinValue) {
      await currentPage?.animateTo(_animationMinValue);
    }
  }

  void updateCurrentPage(double value) {
    if (isNextPageNone) {
      return;
    }
    currentPage?.value = value;
  }

  void updatePreviousPage(double value) {
    if (isPreviousPageNone) {
      return;
    }
    previousPage?.value = value;
  }

  Future<void> turnNextPage() async {
    if (isNextPageNone) {
      return;
    }
    currentPage?.animateTo(_animationMaxValue);
    currentIndex++;
    onPageChanged?.call(currentIndex);
    // print('-----currentIndex: $currentIndex');
    if (currentIndex + 1 >= itemCount) {
      return;
    }
    visibleNotifierList[currentIndex + 1].value = true;
  }

  Future<void> turnPreviousPage() async {
    if (isPreviousPageNone) {
      return;
    }
    previousPage?.animateTo(_animationMinValue);
    currentIndex--;
    onPageChanged?.call(currentIndex);
    if (currentIndex - 1 < 0) {
      return;
    }
    visibleNotifierList[currentIndex - 1].value = true;
  }

  void jump(int index) {
    final diff = currentIndex - index;
    if (diff == 0) {
      return;
    }

    final isForward = diff < 0;
    for (var i = 0; i < itemCount; i++) {
      if (i == currentIndex) {
        continue;
      } else if (i < index) {
        _controllers[i].value = 1.0;
      } else {
        _controllers[i].value = 0.0;
      }
      _controllers[index].value = isForward ? 0.0 : 1.0;
    }
    if (isForward) {
      _controllers[currentIndex].animateTo(1.0);
    } else {
      _controllers[index].value = 1.0;
      _controllers[index].animateTo(0.0);
    }
    currentIndex = index;
    onPageChanged?.call(currentIndex);
    visibleNotifierList[index].value = true;
    if (currentIndex - 1 >= 0) {
      visibleNotifierList[currentIndex - 1].value = true;
    }
    if (currentIndex + 1 < itemCount) {
      visibleNotifierList[currentIndex + 1].value = true;
    }
  }
}
