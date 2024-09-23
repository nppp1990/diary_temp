import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/widgets/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pageviewj/pageviewj.dart';

class EditMoodPage extends StatelessWidget {
  const EditMoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Mood'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: const EditMoodPageContent(),
    );
  }
}

class EditMoodPageContent extends StatefulWidget {
  const EditMoodPageContent({super.key});

  @override
  State<StatefulWidget> createState() => _EditMoodPageContentState();
}

class _EditMoodPageContentState extends State<EditMoodPageContent> {
  late ValueNotifier<bool> _isOneDayMood;

  @override
  void initState() {
    super.initState();
    _isOneDayMood = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _isOneDayMood.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 36),
          ValueListenableBuilder(
            valueListenable: _isOneDayMood,
            builder: (context, value, child) {
              return Text(
                'How are you feeling ${value ? 'today' : 'now'}?',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              );
            },
          ),
          const SizedBox(height: 20),
          const MoodPageView(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.pagePadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Is this one day mood?', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                ValueListenableBuilder(
                  valueListenable: _isOneDayMood,
                  builder: (context, value, child) {
                    return Switch(
                      inactiveThumbColor: TestColors.primary,
                      trackOutlineColor: WidgetStateProperty.all(TestColors.primary),
                      activeTrackColor: TestColors.primary,
                      value: value,
                      onChanged: (value) {
                        _isOneDayMood.value = value;
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.pagePadding),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Add a note',
                  hintStyle: const TextStyle(color: TestColors.grey1),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: TestColors.black1, width: 2),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: TestColors.primary, width: 2),
                  ),
                ),
                maxLines: null,
                maxLength: 80,
              )),
        ],
      ),
    );
  }
}

class MoodPageView extends StatefulWidget {
  const MoodPageView({super.key});

  @override
  State<StatefulWidget> createState() => _MoodPageViewState();
}

class _MoodPageViewState extends State<MoodPageView> {
  List<String> get moods => TestConfiguration.moodImages;

  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: 0,
      viewportFraction: 0.5,
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _controller.animateToPage(2, duration: const Duration(milliseconds: 300 * 2), curve: Curves.easeInOut);
        }
      });
    });
  }

  Widget _buildIMoodItem(BuildContext context, int index, double page, double aniValue, double width) {
    Widget buildBubbleTip(BuildContext context, String text) {
      return AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.zero,
        child: BubbleBorder(
          borderRadius: 6,
          direction: TriangleDirection.topCenter,
          triangleWidth: 8,
          triangleHeight: 6,
          triangleOffset: 0,
          strokeWidth: 1,
          strokeColor: Colors.transparent,
          fillColor: TestColors.primary,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: 0.5 + 0.5 * aniValue,
          child: SvgPicture.asset(
            moods[index],
            width: width * 0.7 + width * 0.3 * aniValue,
            height: width * 0.7 + width * 0.3 * aniValue,
          ),
        ),
        const SizedBox(height: 6),
        if (page == index.toDouble()) buildBubbleTip(context, TestConfiguration.moodTexts[index]),
        // Expanded(
        //     child: Center(
        //   child: Text('index: $index, page: $page, aniValue: $aniValue'),
        // )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return SizedBox(
      height: screenWidth * _controller.viewportFraction + 80,
      child: PageViewJ.aniBuilder(
        controller: _controller,
        itemCount: moods.length,
        aniItemBuilder: (context, index, page, aniValue) {
          return _buildIMoodItem(context, index, page, aniValue, screenWidth * _controller.viewportFraction);
        },
      ),
    );
  }
}
