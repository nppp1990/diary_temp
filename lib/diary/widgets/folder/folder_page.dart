import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/data/bean/folder.dart';
import 'package:dribbble/diary/data/bean/record.dart';
import 'package:dribbble/diary/data/sqlite_helper.dart';
import 'package:dribbble/diary/utils/dialog_utils.dart';
import 'package:dribbble/diary/utils/docs.dart';
import 'package:dribbble/diary/utils/time_utils.dart';
import 'package:dribbble/diary/widgets/calendar/calendar_dialog.dart';
import 'package:dribbble/diary/widgets/coli.dart';
import 'package:dribbble/diary/widgets/folder/book_one_day.dart';
import 'package:dribbble/diary/widgets/folder/folders_page.dart';
import 'package:dribbble/diary/widgets/list/diary_list.dart';
import 'package:dribbble/diary/widgets/list/diary_list3.dart';
import 'package:dribbble/diary/widgets/loading.dart';
import 'package:dribbble/diary/widgets/menu/home.dart';
import 'package:dribbble/diary/widgets/turn/turn_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FolderPage extends StatelessWidget {
  final Folder folder;

  const FolderPage({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    var bookHeight = MediaQuery.sizeOf(context).height * 0.7;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TestConfiguration.pagePadding),
        child: DiaryBook(
          folder: folder,
          coliPaddingLeft: 16,
          height: bookHeight,
        ),
      ),
      floatingActionButton: ItemsActionButton(
        onItemTap: (index) {},
      ),
    );
  }
}

class DiaryBook extends StatefulWidget {
  static const double bookRadius = 16;

  // final List<DiaryRecord> records;
  final Folder folder;
  final double coliPaddingLeft;
  final double height;

  const DiaryBook({
    super.key,
    required this.folder,
    required this.coliPaddingLeft,
    required this.height,
  });

  @override
  State<StatefulWidget> createState() => _DiaryBookState();
}

class _DiaryBookState extends State<DiaryBook> {
  double get coliPaddingLeft => widget.coliPaddingLeft;

  double get height => widget.height;

  Folder get folder => widget.folder;

  late TurnPageController _pageController;

  late ValueNotifier<int?> _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = ValueNotifier(null);
    _pageController = TurnPageController(
      initialPage: 0,
      duration: const Duration(seconds: 1),
      cornerRadius: 10,
      onPageChanged: (index) {
        _currentIndex.value = index;
      },
    );
  }

  @override
  void dispose() {
    _currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('----build book height: $height');
    double coliWidth = coliPaddingLeft * 386 / 148;
    double coliHeight = coliWidth * 179 / 386;
    int coliCount = (height - coliHeight * 0.5) ~/ (coliHeight * 1.5);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height,
            child: Stack(
              children: [
                FutureLoading<List<DiaryRecord>, Map<DateKey, List<DiaryRecord>>>(
                  futureBuilder: () async {
                    await Future.delayed(const Duration(seconds: 1));
                    return RecordManager().getAllRecord(timeSortDesc: false);
                  },
                  convert: DocUtils.groupRecordsByDate2,
                  contentBuilder: (context, recordMap) {
                    return Padding(
                      padding: EdgeInsets.only(left: coliPaddingLeft),
                      child: _BookPageStateWidget(
                        pageController: _pageController,
                        recordMap: recordMap,
                        height: height,
                        padding: EdgeInsets.only(left: coliWidth - coliPaddingLeft + 10, right: 10),
                        coverPage: BookCover(
                          folder: folder,
                          borderRadius: DiaryBook.bookRadius,
                        ),
                        endPage: const BlankBookItem(
                          child: Center(
                            child: Text(
                              'End',
                              style: TextStyle(
                                fontSize: 24,
                                color: TestColors.black1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  placeParentBuilder: (context, child) {
                    return Padding(
                      padding: EdgeInsets.only(left: coliPaddingLeft),
                      child: BlankBookItem(
                        child: child,
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(coliCount, (index) {
                      return Padding(
                        padding: EdgeInsets.only(
                            top: coliHeight * 0.5, bottom: index == coliCount - 1 ? coliHeight * 0.5 : 0),
                        child: Coil(
                          coilColor: TestColors.black1,
                          width: coliWidth,
                        ),
                      );
                    }),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: coliPaddingLeft),
              ValueListenableBuilder(
                  valueListenable: _currentIndex,
                  builder: (context, value, child) {
                    return _buildBtn(
                      text: 'Pre',
                      onPressed: value != null && value > 0 ? _prePage : null,
                    );
                  }),
              const SizedBox(width: 16),
              ValueListenableBuilder<int?>(
                  valueListenable: _currentIndex,
                  builder: (BuildContext context, int? value, Widget? child) {
                    return _buildBtn(
                        text: 'Next',
                        onPressed: (value != null && value < _pageController.itemCount - 1) ? _nextPage : null);
                  }),
            ],
          ),
        ],
      ),
    );
  }

  _nextPage() {
    _pageController.nextPage();
  }

  _prePage() {
    _pageController.previousPage();
  }

  Widget _buildBtn({required String text, VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: const BorderSide(color: TestColors.black1, width: 2),
        // backgroundColor: TestColors.second,
        foregroundColor: TestColors.black1,
        minimumSize: const Size(100, 0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _BookPageStateWidget extends StatefulWidget {
  final TurnPageController pageController;
  final Map<DateKey, List<DiaryRecord>> recordMap;
  final double height;
  final EdgeInsetsGeometry padding;
  final Widget coverPage;
  final Widget endPage;

  const _BookPageStateWidget({
    required this.pageController,
    required this.recordMap,
    required this.height,
    required this.padding,
    required this.coverPage,
    required this.endPage,
  });

  @override
  State<StatefulWidget> createState() => _BookPageState();
}

class _BookPageState extends State<_BookPageStateWidget> {

  TurnPageController get pageController => widget.pageController;

  Map<DateKey, List<DiaryRecord>> get recordMap => widget.recordMap;

  @override
  Widget build(BuildContext context) {
    return TurnPageView.builder(
      controller: pageController,
      itemCount: recordMap.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return widget.coverPage;
        }
        if (index == recordMap.length + 1) {
          return widget.endPage;
        }
        final date = recordMap.keys.elementAt(index - 1);
        final records = recordMap[date]!;
        return _BookPageItem(
          dateTime: date.toDateTime(),
          records: records,
          data: BaseListView.generateTestListData(records),
          index: index,
          height: widget.height,
          borderRadius: DiaryBook.bookRadius,
          padding: widget.padding,
          onDateTap: () => _onClickDate(context, recordMap, date),
        );
      },
      overleafColorBuilder: (index) => TestColors.grey1,
      animationTransitionPoint: 0.35,
    );
  }

  void _onClickDate(BuildContext context, final Map<DateKey, List<DiaryRecord>> recordsMap, final DateKey date) async {
    var time = await DiaryCalendarDialog.show(context, recordsMap: recordsMap, selectedDay: date.toDateTime());
    if (time != null && time is DateTime) {
      print('selected time: $time');
      DateKey key = DateKey.fromDateTime(time);
      int index = recordsMap.keys.toList().indexOf(key);
      if (!context.mounted) {
        return;
      }
      if (index == -1) {
        DialogUtils.showToast(context, 'No record on ${time.toDateString()}');
      } else {
        int currentIndex = pageController.currentIndex;
        if (index + 1 != currentIndex) {
          pageController.animateToPage(index + 1);
        }
      }
    }
  }
}

class _BookPageItem extends StatelessWidget {
  final int index;
  final DateTime dateTime;
  final List<DiaryRecord> records;
  final List<TestInfo> data;

  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onDateTap;

  const _BookPageItem({
    required this.index,
    required this.dateTime,
    required this.records,
    required this.data,
    required this.height,
    required this.borderRadius,
    this.padding,
    this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: BookPageItemContent(
        index: index,
        dateTime: dateTime,
        records: records,
        data: data,
        height: height,
        borderRadius: borderRadius,
        padding: padding,
        onDateTap: onDateTap,
      ),
    );
  }
}

class BookPageItemContent extends StatefulWidget {
  final int index;
  final DateTime dateTime;
  final List<DiaryRecord> records;
  final List<TestInfo> data;

  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onDateTap;

  const BookPageItemContent({
    super.key,
    required this.index,
    required this.dateTime,
    required this.records,
    required this.data,
    required this.height,
    required this.borderRadius,
    this.padding,
    this.onDateTap,
  });

  @override
  State<StatefulWidget> createState() => BookPageItemContentState();
}

class BookPageItemContentState extends State<BookPageItemContent> {
  int get index => widget.index;

  DateTime get dateTime => widget.dateTime;

  List<DiaryRecord> get records => widget.records;

  List<TestInfo> get data => widget.data;

  double get height => widget.height;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dayMood = DocUtils.getDayMood(records);
    print('---------build BookPageItemContent: $dayMood');
    return BookPageItemContentProvider(
      state: this,
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Mood: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: TestColors.black1,
                  ),
                ),
                if (dayMood != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: SvgPicture.asset(
                      TestConfiguration.moodImages[dayMood],
                      width: 18,
                      height: 18,
                    ),
                  ),
                const Spacer(),
                SizedBox(
                  height: 22,
                  child: TextButton(
                    onPressed: widget.onDateTap,
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      foregroundColor: TestColors.primary,
                    ),
                    child: Text(
                      '${TimeUtils.getWeekdayStr(dateTime)}, ${TimeUtils.getDateStr(dateTime)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 2,
            color: TestColors.black1,
          ),
          const SizedBox(height: 2),
          Container(
            width: double.infinity,
            height: 2,
            color: TestColors.black3,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: OneDayItem(
                dateTime: dateTime,
                records: records,
                data: data,
              ),
            ),
          ),
        ],
      ),
    );
  }

  refresh({
    GlobalKey<DiaryListItemState>? changedItemKey,
    Offset? parentPosition,
    Size? parentSize,
  }) {
    print('------refresh BookPageItemContent');
    setState(() {
      records.sort((a, b) => a.time.compareTo(b.time));
      data.sort((a, b) => a.time.compareTo(b.time));
    });
    if (changedItemKey == null || parentPosition == null || parentSize == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final RenderBox renderBox = changedItemKey.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      print(
          '-----position: ${position.dy}----parentPosition: ${parentPosition.dy}----scroll: ${_scrollController.position}---offset: ${_scrollController.offset}---parentSize: $parentSize');
      if (position.dy > parentPosition.dy &&
          position.dy + renderBox.size.height < parentPosition.dy + parentSize.height) {
        print('-----1');
        changedItemKey.currentState?.triggerItemTap();
      } else {
        print('-----2');
        var animateRes = _scrollController.animateTo(
          _scrollController.offset - parentPosition.dy + position.dy,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        animateRes.then((_) => changedItemKey.currentState?.triggerItemTap());
      }
    });
  }
}

class BookPageItemContentProvider extends InheritedWidget {
  final BookPageItemContentState state;

  const BookPageItemContentProvider({
    super.key,
    required this.state,
    required super.child,
  });

  static BookPageItemContentState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BookPageItemContentProvider>()?.state;
  }

  @override
  bool updateShouldNotify(covariant BookPageItemContentProvider oldWidget) {
    return state != oldWidget.state;
  }
}

class BlankBookItem extends StatelessWidget {
  final Widget? child;

  const BlankBookItem({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          border: Border.all(color: TestColors.black1, width: 2),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(DiaryBook.bookRadius),
            bottomRight: Radius.circular(DiaryBook.bookRadius),
          )),
      child: child,
    );
  }
}
