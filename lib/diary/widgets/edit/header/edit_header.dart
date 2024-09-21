import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/widgets/bubble.dart';
import 'package:dribbble/diary/widgets/icon/arrow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EditHeader1 extends StatelessWidget {
  const EditHeader1({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.editHeaderPadding),
      child: SizedBox(
        height: TestConfiguration.editHeaderHeight,
        child: Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                  width: TestConfiguration.editHeaderItemSize,
                  height: TestConfiguration.editHeaderItemSize,
                  decoration: BoxDecoration(
                    color: TestColors.second,
                    borderRadius: BorderRadius.circular(8),
                    border: const Border.fromBorderSide(BorderSide(color: TestColors.black1, width: 2)),
                  ),
                  child: const Center(
                    child: LeftArrow(
                      color: TestColors.black1,
                      strokeWidth: 2,
                      size: 16,
                    ),
                  )),
            ),
            const Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop();
              },
              child: SvgPicture.asset(
                'assets/icons/ic_right.svg',
                colorFilter: const ColorFilter.mode(TestColors.black1, BlendMode.srcIn),
                width: 16,
                height: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditHeader2 extends StatelessWidget {
  const EditHeader2({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: TestConfiguration.editHeaderPadding),
      child: SizedBox(
        height: TestConfiguration.editHeaderHeight,
        child: Row(
          children: [
            Text(
              '20 sep 2021 12:00',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Spacer(),
            _EmotionSelector(),
          ],
        ),
      ),
    );
  }
}

class _EmotionSelector extends StatefulWidget {
  final int? emotionIndex;

  const _EmotionSelector({this.emotionIndex});

  @override
  State<StatefulWidget> createState() => _EmotionSelectorState();
}

class _EmotionSelectorState extends State<_EmotionSelector> {
  late int? _index;

  @override
  void initState() {
    super.initState();
    _index = widget.emotionIndex;
    if (_index == null) {
      // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //   _showBubbleGuideDialog(context);
      // });
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (context.mounted) {
          _showBubbleGuideDialog(context);
        }
      });
    }
  }

  List<String> get emotions => TestConfiguration.moodImages;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _showBubbleGuideDialog(context);
      },
      child: SvgPicture.asset(
        emotions[_index ?? 0],
        width: TestConfiguration.editHeaderItemSize,
        height: TestConfiguration.editHeaderItemSize,
      ),
    );
  }

  _showBubbleGuideDialog(BuildContext context) async {
    final renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    var screenWidth = MediaQuery.sizeOf(context).width;
    final triangleOffset = screenWidth - offset.dx - TestConfiguration.editHeaderPadding - 10;

    var res = await showDialog(
      context: context,
      useSafeArea: false,
      builder: (BuildContext context) {
        return EmotionBubbleDialog(
          top: offset.dy + renderBox.size.height,
          right: TestConfiguration.editHeaderPadding,
          triangleOffset: triangleOffset,
        );
      },
    );
    if (res != null && res is int) {
      setState(() {
        _index = res;
      });
    }
  }
}

class EmotionBubbleDialog extends StatelessWidget {
  final double top;
  final double right;
  final double triangleOffset;

  const EmotionBubbleDialog({super.key, required this.top, required this.right, required this.triangleOffset});

  List<String> get emotions => TestConfiguration.moodImages;

  List<String> get emotionTexts => TestConfiguration.moodTexts;

  @override
  Widget build(BuildContext context) {
    const padding = TestConfiguration.editHeaderPadding;
    return AnimatedPadding(
      padding: EdgeInsets.zero,
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Stack(
        children: [
          Positioned(
            top: top,
            right: right,
            child: BubbleBorder(
                triangleWidth: 20,
                triangleHeight: 10,
                triangleOffset: triangleOffset,
                borderRadius: 12,
                strokeWidth: 1,
                strokeColor: const Color(0xFF919191),
                fillColor: const Color(0xFFECEAED),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: padding),
                    const Padding(
                      padding: EdgeInsets.only(left: padding),
                      child: Text('how are you feeling?',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                    const SizedBox(height: 2),
                    _buildEmotionList(context, 0),
                    _buildEmotionList(context, 4),
                    const SizedBox(height: padding / 2),
                  ],
                )),
          )
        ],
      ),
    );
  }

  Widget _buildEmotionList(BuildContext context, int startIndex) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: TestConfiguration.editHeaderPadding / 2,
        ),
        for (int i = startIndex; i < startIndex + 4; i++)
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop(i);
            },
            child: Tooltip(
              message: emotionTexts[i],
              child: Padding(
                padding: const EdgeInsets.all(TestConfiguration.editHeaderPadding / 2),
                child: SvgPicture.asset(
                  emotions[i],
                  width: TestConfiguration.editHeaderItemSize,
                  height: TestConfiguration.editHeaderItemSize,
                ),
              ),
            ),
          ),
        const SizedBox(width: TestConfiguration.editHeaderPadding / 2)
      ],
    );
  }
}
