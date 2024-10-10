import 'package:dribbble/diary/data/bean/record.dart';
import 'package:dribbble/diary/utils/dialog_utils.dart';
import 'package:dribbble/diary/widgets/edit/edit_demo3.dart';
import 'package:dribbble/diary/widgets/emotion/edit_mood.dart';
import 'package:dribbble/diary/widgets/folder/folder_page.dart';
import 'package:dribbble/diary/widgets/list/diary_list.dart';
import 'package:dribbble/diary/widgets/list/diary_list3.dart';
import 'package:dribbble/diary/widgets/router_utils.dart';
import 'package:dribbble/diary/widgets/simple/event_dialog.dart';
import 'package:flutter/material.dart';

class OneDayItem extends StatefulWidget {
  final DateTime dateTime;
  final List<DiaryRecord> records;
  final List<TestInfo> data;

  const OneDayItem({
    super.key,
    required this.dateTime,
    required this.records,
    required this.data,
  });

  @override
  State<StatefulWidget> createState() => _OneDayItem();
}

class _OneDayItem extends State<OneDayItem> {
  final Map<int, GlobalKey<DiaryListItemState>> _itemKeys = {};
  int? _changedRecordId;
  OverlayEntry? _overlayEntry;

  List<TestInfo> get data => widget.data;

  List<DiaryRecord> get records => widget.records;

  static const _menuWidth = 180.0;
  static const _menuItemHeight = 24.0 + 16.0 * 2;

  Offset _parentPosition = Offset.zero;
  Size _parentSize = Size.zero;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < data.length; i++) {
      _itemKeys[data[i].record.id!] = GlobalKey();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var renderBox = context.findRenderObject() as RenderBox;
      _parentPosition = renderBox.localToGlobal(Offset.zero);
      _parentSize = renderBox.size;
    });
  }

  @override
  void dispose() {
    _hideContextMenu();
    super.dispose();
  }

  _hideContextMenu() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  void _editRecord(int recordIndex) async {
    var record = data[recordIndex].record;
    dynamic res;
    switch (record.type) {
      case RecordType.mood:
        res = await MoodDialog.showMoodDialog(context, record: record);
        break;
      case RecordType.event:
        res = await SimpleEventDialog.showEventDialog(context, record: record);
        break;
      case RecordType.diary:
        res = await Navigator.push(context, Left2RightRouter(child: TestEdit(record: record)));
        break;
    }
    if (res is DiaryRecord && mounted) {
      _changedRecordId = res.id;
      data[recordIndex] = TestInfo.fromRecord(res);
      records[recordIndex] = res;
      BookPageItemContentProvider.of(context)?.refresh(
        changedItemKey: _itemKeys[record.id!]!,
        parentPosition: _parentPosition,
        parentSize: _parentSize,
      );
    }
  }

  void _deleteRecord(int recordIndex) async {
    var record = data[recordIndex].record;
    final String title;
    final String content;
    switch (record.type) {
      case RecordType.mood:
        title = 'Delete Mood';
        content = 'After deleting the mood, the all day mood may be changed. Are you sure to delete this mood?';
        break;
      case RecordType.event:
        title = 'Delete Event';
        content = 'Are you sure to delete this event?';
        break;
      case RecordType.diary:
        title = 'Delete Diary';
        if (record.mood != null) {
          content = 'After deleting the diary, the all day mood may be changed. Are you sure to delete this diary?';
        } else {
          content = 'Are you sure to delete this diary?';
        }
        break;
    }
    var res = await DialogUtils.showConfirmDialog(context, title: title, content: content);
    if (res is int && res > 0 && mounted) {
      data.removeAt(recordIndex);
      records.removeAt(recordIndex);
      BookPageItemContentProvider.of(context)?.refresh();
      // RecordManager().deleteRecord(record.id!);
    }
  }

  _showMoreContextMenu(
      BuildContext itemContext,
      BuildContext triggerContext,
      int recordIndex,
      Offset? position,
      ) {
    Widget buildMenuItem(String title, IconData icon, Function() onAction) {
      return SizedBox(
        height: _menuItemHeight,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(icon, size: 24),
          title: Text(title),
          onTap: () {
            _hideContextMenu();
            onAction();
          },
        ),
      );
    }

    TestInfo testInfo = data[recordIndex];
    int itemCount = testInfo.type == RecordType.diary ? 3 : 2;

    _overlayEntry = DialogUtils.getContextMenuOverlay(
      triggerContext,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return buildMenuItem('Edit', Icons.edit_outlined, () {
              _editRecord(recordIndex);
              // todo
            });
          case 1:
            return buildMenuItem('Delete', Icons.delete_outline, () {
              _deleteRecord(recordIndex);
            });
          case 2:
            return buildMenuItem('View', Icons.visibility_outlined, () {});
          default:
            return const SizedBox();
        }
      },
      menuHeight: _menuItemHeight * itemCount,
      menuWidth: _menuWidth,
      hideContextMenu: _hideContextMenu,
      position: position,
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void didUpdateWidget(covariant OneDayItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('-------didUpdateWidget one day item');
  }

  @override
  Widget build(BuildContext context) {
    print('-------build one day item');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // date header
        for (int i = 0; i < data.length; i++)
          DiaryListItem(
            key: _itemKeys[data[i].record.id!],
            data: data[i],
            isTop: i == 0,
            isBottom: i == data.length - 1,
            isOnlyOne: data.length == 1,
            maxLines: 5,
            onMoreTap: (itemContext, triggerContext, position) {
              _showMoreContextMenu(itemContext, triggerContext, i, position);
            },
          ),
        // diary content
      ],
    );
  }
}