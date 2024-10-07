import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/data/bean/folder.dart';
import 'package:dribbble/diary/data/bean/record.dart';
import 'package:dribbble/diary/data/sqlite_helper.dart';
import 'package:dribbble/diary/utils/docs.dart';
import 'package:dribbble/diary/utils/time_utils.dart';
import 'package:dribbble/diary/widgets/coli.dart';
import 'package:dribbble/diary/widgets/folder/folders_page.dart';
import 'package:dribbble/diary/widgets/list/diary_list.dart';
import 'package:dribbble/diary/widgets/list/diary_list3.dart';
import 'package:dribbble/diary/widgets/loading.dart';
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
    double coliWidth = coliPaddingLeft * 386 / 148;
    double coliHeight = coliWidth * 179 / 386;
    int coliCount = (height - coliHeight * 0.5) ~/ (coliHeight * 1.5);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height,
          child: Stack(
            children: [
              FutureLoading<List<DiaryRecord>, Map<DateTime, List<DiaryRecord>>>(
                futureBuilder: () async {
                  await Future.delayed(const Duration(seconds: 1));
                  return RecordManager().getAllRecord(timeSortDesc: false);
                },
                convert: DocUtils.groupRecordsByDate,
                contentBuilder: (context, recordMap) {
                  return Padding(
                    padding: EdgeInsets.only(left: coliPaddingLeft),
                    child: TurnPageView.builder(
                      controller: _pageController,
                      itemCount: recordMap.length + 2,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return BookCover(
                            folder: folder,
                            borderRadius: DiaryBook.bookRadius,
                          );
                        }
                        if (index == recordMap.length + 1) {
                          return const BlankBookItem(
                            child: Center(
                              child: Text(
                                'End',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: TestColors.black1,
                                ),
                              ),
                            ),
                          );
                        }
                        final date = recordMap.keys.elementAt(index - 1);
                        final records = recordMap[date]!;
                        return _BookPageItem(
                            dateTime: date,
                            records: records,
                            data: BaseListView.generateTestListData(records),
                            index: index,
                            height: height,
                            borderRadius: DiaryBook.bookRadius,
                            padding: EdgeInsets.only(
                              left: coliWidth - coliPaddingLeft + 10,
                              right: 10,
                            ));
                      },
                      overleafColorBuilder: (index) => TestColors.grey1,
                      animationTransitionPoint: 0.35,
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
                      padding:
                          EdgeInsets.only(top: coliHeight * 0.5, bottom: index == coliCount - 1 ? coliHeight * 0.5 : 0),
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
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    print('-----currentIndex: $value');
                    return _buildBtn(
                        text: 'Next',
                        onPressed: (value != null && value < _pageController.itemCount - 1) ? _nextPage : null);
                  }),
            ],
          ),
        ),
      ],
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

class _BookPageItem extends StatelessWidget {
  final int index;
  final DateTime dateTime;
  final List<DiaryRecord> records;
  final List<TestInfo> data;

  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const _BookPageItem({
    required this.index,
    required this.dateTime,
    required this.records,
    required this.data,
    required this.height,
    required this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    var dayMood = DocUtils.getDayMood(records);
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
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => FoldersPage()));
                    // todo 选择时间
                    print('-----index: $index');
                  },
                  child: Text(
                    '${TimeUtils.getWeekdayStr(dateTime)}, ${TimeUtils.getDateStr(dateTime)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: TestColors.black1,
                    ),
                  ),
                ),
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
