import 'dart:math';

import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/data/bean/folder.dart';
import 'package:dribbble/diary/data/local_storage.dart';
import 'package:dribbble/diary/data/sqlite_helper.dart';
import 'package:dribbble/diary/utils/dialog_utils.dart';
import 'package:dribbble/diary/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'folder_edit.dart';

enum FolderAction { modify, delete, setDefault }

/// 不同入口：管理文件夹、选择文件夹
class FoldersPage extends StatelessWidget {
  final int? folderId;

  const FoldersPage({super.key, this.folderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Folders'),
      ),
      // get list and default id
      body: FutureLoading<Map, Map>(
        convert: (res) => res,
        futureBuilder: () async {
          List<Folder> folderList = await FolderManager().getAllFolders();
          int? defaultFolderId = await LocalStorage.getData<int>(LocalStorage.folderDefault);
          return {'folderList': folderList, 'defaultFolderId': defaultFolderId};
        },
        contentBuilder: (context, map) {
          return _FolderList(folderList: map['folderList'], defaultFolderId: map['defaultFolderId']);
        },
      ),
    );
  }
}

class _FolderList extends StatefulWidget {
  final List<Folder> folderList;
  final int? defaultFolderId;

  const _FolderList({required this.folderList, this.defaultFolderId});

  @override
  State<StatefulWidget> createState() => _FolderListState();
}

class _FolderListState extends State<_FolderList> {
  late List<Folder> _folderList;
  final GlobalKey<AnimatedGridState> _gridKey = GlobalKey<AnimatedGridState>();
  int? _defaultFolderId;

  OverlayEntry? _overlayEntry;
  static const _menuWidth = 180.0;
  static const _menuItemHeight = 24.0 + 16.0 * 2;
  static const _menuHeight = _menuItemHeight * 3;

  @override
  void initState() {
    super.initState();
    _folderList = widget.folderList;
    _defaultFolderId = widget.defaultFolderId;
  }

  @override
  void dispose() {
    super.dispose();
    _hideContextMenu();
  }

  @override
  void didUpdateWidget(covariant _FolderList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.folderList != widget.folderList) {
      _folderList = widget.folderList;
    }
  }

  _hideContextMenu() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  _showContextMenu(BuildContext context, int index, bool isLeft) {
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

    _overlayEntry = DialogUtils.getContextMenuOverlay(
      context,
      itemCount: 3,
      itemBuilder: (_, i) {
        switch (i) {
          case 0:
            return buildMenuItem('Modify', Icons.edit_outlined, () => _handleAction(FolderAction.modify, index));
          case 1:
            return buildMenuItem('Delete', Icons.delete_outline, () => _handleAction(FolderAction.delete, index));
          case 2:
            return buildMenuItem(
                'Set default', Icons.star_outline_rounded, () => _handleAction(FolderAction.setDefault, index));
          default:
            return const SizedBox();
        }
      },
      menuHeight: _menuItemHeight * 3,
      menuWidth: _menuWidth,
      hideContextMenu: _hideContextMenu,
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    print('----build _FolderList defaultFolderId: $_defaultFolderId');
    return AnimationLimiter(
      child: AnimatedGrid(
        key: _gridKey,
        initialItemCount: _folderList.length + 1,
        padding: const EdgeInsets.only(
          top: TestConfiguration.pagePadding,
          left: TestConfiguration.pagePadding,
          right: TestConfiguration.pagePadding,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index, animation) {
          final folder = index < _folderList.length ? _folderList[index] : null;
          return _buildAnimatedItem(context, index, folder, animation);
        },
      ),
    );
  }

  void _handleAction(FolderAction action, int index) {
    switch (action) {
      case FolderAction.modify:
        _modifyItem(index);
        break;
      case FolderAction.delete:
        _removeItem(index);
        break;
      case FolderAction.setDefault:
        _setDefaultFolder(index);
        break;
    }
  }

  void _modifyItem(int index) async {
    Folder folder = _folderList[index];
    var res = await FolderEditContent.show(context, folder: folder);
    if (res is Folder) {
      setState(() {
        _folderList[index] = res;
      });
      FolderManager().updateFolder(res);
    }
  }

  void _onItemClick(int index, Folder? folder) async {
    if (folder == null) {
      var res = await FolderEditContent.show(context);
      if (res is Folder) {
        _addItem(index, res);
      }
    } else {
      // todo: 进入文件夹
    }
  }

  void _addItem(int index, Folder folder) {
    _folderList.insert(index, folder);
    FolderManager().insertFolder(folder);
    _gridKey.currentState?.insertItem(index);
  }

  void _removeItem(int index) {
    Folder folder = _folderList.removeAt(index);
    FolderManager().deleteFolder(folder.id);
    _gridKey.currentState?.removeItem(index, (context, animation) {
      return _buildAnimatedItem(context, index, folder, animation);
    });
  }

  void _setDefaultFolder(int index) {
    Folder folder = _folderList[index];
    if (folder.id == _defaultFolderId) {
      return;
    }
    _defaultFolderId = folder.id;
    LocalStorage.saveData(LocalStorage.folderDefault, folder.id);
    setState(() {});
  }

  Widget _buildAnimatedItem(BuildContext context, int index, Folder? folder, Animation<double> animation) {
    return AnimationConfiguration.staggeredGrid(
      position: index,
      duration: const Duration(milliseconds: 500),
      columnCount: 3,
      child: SlideAnimation(
        verticalOffset: 150.0,
        child: ScaleTransition(
          scale: animation,
          child: FadeInAnimation(
            child: BookCover(
              folder: folder,
              isDefault: folder?.id == _defaultFolderId,
              onItemTap: () => _onItemClick(index, folder),
              onMoreTap: (context) {
                _showContextMenu(context, index, index % 3 == 0);
              },
              borderRadius: 12,
              isSmall: true,
            ),
          ),
        ),
      ),
    );
  }
}

typedef MoreTapCallback = void Function(BuildContext context);

class BookCover extends StatelessWidget {
  final Folder? folder;
  final GestureTapCallback? onItemTap;
  final MoreTapCallback? onMoreTap;
  final bool isDefault;
  final double borderRadius;
  final bool isSmall;

  const BookCover({
    super.key,
    this.folder,
    this.onItemTap,
    this.onMoreTap,
    this.isDefault = false,
    this.borderRadius = 16,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: folder?.backgroundColor ?? Colors.white,
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(borderRadius),
        bottomRight: Radius.circular(borderRadius),
      ),
      child: InkWell(
        onTap: onItemTap,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
        child: Container(
          decoration: BoxDecoration(
            image: folder?.backgroundImage != null
                ? DecorationImage(
                    image: AssetImage(folder!.backgroundImage!),
                    fit: BoxFit.cover,
                  )
                : null,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(borderRadius),
              bottomRight: Radius.circular(borderRadius),
            ),
            border: Border.all(color: TestColors.black1, width: 2),
          ),
          child: folder == null ? _buildAddItem() : _buildItem(folder!, onMoreTap, isSmall, borderRadius),
        ),
      ),
    );
  }

  Widget _buildAddItem() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add,
            color: TestColors.primary,
            size: 36,
          ),
          SizedBox(height: 8),
          Text(
            'Add Folder',
            style: TextStyle(color: TestColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(Folder folder, MoreTapCallback? onMoreTap, bool isSmall, double countRadius) {
    return Stack(
      children: [
        if (onMoreTap != null)
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              width: isSmall ? 30 : 36,
              height: isSmall ? 30 : 36,
              child: Builder(builder: (context) {
                return IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => onMoreTap.call(context),
                  icon: Icon(
                    Icons.more_vert_outlined,
                    color: TestColors.black1,
                    size: isSmall ? 20 : 24,
                  ),
                );
              }),
            ),
          ),
        Align(
          alignment: Alignment.center,
          child: Text(
            folder.name,
            style: TextStyle(
              fontSize: isSmall ? 16 : 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: EdgeInsets.all(isSmall ? 8 : 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(countRadius),
                bottomRight: Radius.circular(countRadius),
              ),
            ),
            child: Text(
              '${folder.diaryCount}',
              style: TextStyle(color: Colors.white, height: 1, fontSize: isSmall ? 12 : null),
            ),
          ),
        ),
        // 左上角 斜着的default 文字
        if (isDefault)
          const Positioned(
            top: 2,
            left: 2,
            child: Icon(
              Icons.star_outline_rounded,
              color: TestColors.primary,
              size: 24,
            ),
          ),
      ],
    );
  }
}
