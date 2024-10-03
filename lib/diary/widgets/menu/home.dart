import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/widgets/edit/edit_demo3.dart';
import 'package:dribbble/diary/widgets/emotion/edit_mood.dart';
import 'package:dribbble/diary/widgets/simple/event_dialog.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      drawer: const Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: Text('Item 1'),
            ),
            ListTile(
              title: Text('Item 2'),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Home Page'),
      ),
      floatingActionButton: const _ItemsActionButton(),
      // floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //
    );
  }
}

class _ItemsActionButton extends StatefulWidget {
  const _ItemsActionButton();

  @override
  State<StatefulWidget> createState() => _ItemsActionButtonState();
}

class _ItemsActionButtonState extends State<_ItemsActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  OverlayEntry? _overlayEntry;

  static const _textList = [
    'diary',
    'mood',
    'event',
  ];

  static const _iconList = [
    Icons.note_add_outlined,
    Icons.mood_outlined,
    Icons.event_available_outlined,
  ];

  void _showOverlay() {
    _controller.forward();
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              // 这里就是乱写
              bottom: 280,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _removeOverlay,
              ),
            ),
            Positioned.fill(
              right: 150,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _removeOverlay,
              ),
            ),
          ],
        );
      },
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (context.mounted) {
      _overlayEntry?.remove();
      _overlayEntry?.dispose();
      _overlayEntry = null;
      _controller.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(curve: Curves.easeInOut, parent: _controller));
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
    _controller.dispose();
    super.dispose();
  }

  Widget _buildItem(BuildContext context, int index) {
    final screenWidth = MediaQuery
        .sizeOf(context)
        .width;

    TextDirection textDirection = Directionality.of(context);

    // double animationDirection = textDirection == TextDirection.ltr ? -1 : 1;

    final transform = Matrix4.translationValues(
      -1 * (screenWidth - _animation.value * screenWidth) * ((_textList.length - index) / 4),
      0.0,
      0.0,
    );

    return Align(
      alignment: Alignment.centerRight,
      child: Transform(
        transform: transform,
        child: Opacity(
          opacity: _animation.value,
          child: _buildFloatingActionItem(_textList[index], _iconList[index], () {
            _removeOverlay();
            if (index == 0) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TestEditDemo3()));
            } else if (index == 1) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const EditMoodPage()));
            } else if (index == 2) {
              SimpleEventDialog.showEventDialog(context);
            }
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IgnorePointer(
          ignoring: _animation.value == 0,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 12.0),
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: _textList.length,
            itemBuilder: _buildItem,
          ),
        ),
        FloatingActionButton(
          // heroTag: heroTag ?? const _DefaultHeroTag(),
          // backgroundColor: Colors.slimeGreen,
          foregroundColor: TestColors.primary,
          shape: const CircleBorder(
            side: BorderSide(
              color: TestColors.primary,
              width: 1.0,
            ),
          ),
          onPressed: () {
            print('FloatingActionButton tapped');
            if (_controller.isCompleted) {
              _removeOverlay();
            } else {
              // print('forward');
              // _controller.forward();
              _showOverlay();
            }
          },
          child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: _controller.isCompleted
                  ? const Icon(
                Icons.close,
                size: 28,
              )
                  : const Icon(
                Icons.add,
                size: 28,
              )),
        ),
      ],
    );
  }

  _buildFloatingActionItem(String text, IconData icon, VoidCallback onPress) {
    return SizedBox(
      width: 110,
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: TestColors.primary,
          // backgroundColor: TestColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        onPressed: onPress,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 6),
              Text(text, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
