import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/data/bean/record.dart';
import 'package:dribbble/diary/utils/docs.dart';
import 'package:dribbble/diary/widgets/list/diary_list.dart';
import 'package:flutter/material.dart';

class TestListView2 extends StatefulWidget {
  const TestListView2({super.key});

  @override
  State<StatefulWidget> createState() => _TestListView2State();
}

class _TestListView2State extends State<TestListView2> {

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width - TestListView.leftSize - TestConfiguration.pagePadding;
    return BaseListView(contentBuilder: (context, map) {
      return Container(
        color: Colors.white,
        child: ListView.separated(
          itemCount: map.length,
          itemBuilder: (context, index) {
            List<DiaryRecord> records = map.values.elementAt(index);
            DateTime dateTime = map.keys.elementAt(index);
            return _TestItem2(
              width: width,
              dateTime: dateTime,
              records: records,
              data: BaseListView.generateTestListData(records),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Container(height: 1, color: TestColors.greyDivider1);
          },
        ),
      );
    });
  }
}

class _TestItem2 extends StatelessWidget {
  final double width;
  final DateTime dateTime;
  final List<DiaryRecord> records;
  final List<TestInfo> data;

  const _TestItem2({required this.width, required this.dateTime, required this.records, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LeftDateItem(dateTime: dateTime, moodIndex: DocUtils.getDayMood(records)),
        SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < records.length; i++) ...[
                _buildItem(i),
                if (i != records.length - 1) Container(height: 1, color: TestColors.greyDivider1),
              ]
            ],
          ),
        )
      ],
    );
  }

  Widget _buildItem(int index) {
    final item = data[index];
    switch (item.type) {
      case RecordType.event:
        return _ListItem(
            child: EventContentItem(
          note: item.note!,
          dateTime: item.time,
        ));
      case RecordType.mood:
        return _ListItem(
          child: MoodContentItem(
            moodIndex: item.moodIndex!,
            dateTime: item.time,
            note: item.note,
          ),
        );
      case RecordType.diary:
        return _ListItem(
          child: DiaryContentItem(
            note: item.note!,
            dateTime: item.time,
            moodIndex: item.moodIndex,
            checkedCount: item.checkedCount,
            checkCount: item.checkCount,
          ),
        );
    }
  }
}

class _ListItem extends StatelessWidget {
  final Widget child;

  const _ListItem({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          print('----onTap');
        },
        onLongPress: () {
          print('----onLongPress');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: TestListView.itemPadding,
          ),
          child: child,
        ),
      ),
    );
  }
}
