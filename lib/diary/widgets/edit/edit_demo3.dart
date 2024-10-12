import 'dart:convert';

import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/data/bean/record.dart';
import 'package:dribbble/diary/data/bean/template.dart';
import 'package:dribbble/diary/data/sqlite_helper.dart';
import 'package:dribbble/diary/utils/dialog_utils.dart';
import 'package:dribbble/diary/utils/docs.dart';
import 'package:dribbble/diary/utils/keyboard.dart';
import 'package:dribbble/diary/widgets/bg_page.dart';
import 'package:dribbble/diary/widgets/edit/header/edit_header.dart';
import 'package:dribbble/diary/widgets/edit/toolbar/background/background_selector.dart';
import 'package:dribbble/diary/widgets/edit/toolbar/template/template_item.dart';
import 'package:dribbble/diary/widgets/edit/toolbar/template/template_add_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'toolbar/color/color_toolbar_item.dart';
import 'toolbar/emotion/emotion_selector.dart';
import 'toolbar/second_dialog.dart';
import 'toolbar/tool_bar.dart';

class TestEditDemo3 extends StatelessWidget {
  final DiaryRecord? record;

  const TestEditDemo3({super.key, this.record});

  @override
  Widget build(BuildContext context) {
    return DiaryEditPage(record: record);
  }
}

class DiaryEditPage extends StatefulWidget {
  final DiaryRecord? record;

  const DiaryEditPage({super.key, this.record});

  @override
  State<StatefulWidget> createState() => DiaryEditPageState();
}

class DiaryEditPageState extends State<DiaryEditPage> {
  DiaryRecord? get oldRecord => widget.record;

  final QuillController controller = QuillController.basic();
  final FocusNode _focusNode = FocusNode();

  // late bool _showColorDialog;
  late ValueNotifier<bool> _showColorDialogNotifier;
  late ValueNotifier<bool> _showBackgroundDialogNotifier;
  late ValueNotifier<bool> _showEmotionDialogNotifier;

  final GlobalKey<ToolbarTemplateItemState> _templateItemKey = GlobalKey();
  bool _hasShowTemplateTips = false;

  // record data
  int? _moodIndex;
  late DateTime _time;
  late BackgroundController backgroundController;

  @override
  void initState() {
    super.initState();
    _showColorDialogNotifier = ValueNotifier<bool>(false);
    _showBackgroundDialogNotifier = ValueNotifier<bool>(false);
    _showEmotionDialogNotifier = ValueNotifier<bool>(false);
    _focusNode.addListener(_focusChanged);
    _loadData();
  }

  void _focusChanged() {
    final hasFocus = _focusNode.hasFocus;
    if (hasFocus &&
        !_hasShowTemplateTips &&
        controller.document.isEmpty() &&
        !_showColorDialogNotifier.value &&
        !_showBackgroundDialogNotifier.value &&
        !_showEmotionDialogNotifier.value) {
      // 2秒后如果还没有输入内容，显示模板提示
      Future.delayed(const Duration(seconds: 2), () {
        if (controller.document.isEmpty() && _templateItemKey.currentState != null) {
          _templateItemKey.currentState?.showBubbleDialog(true);
          _hasShowTemplateTips = true;
        }
      });
    }
  }

  @override
  void dispose() {
    _showColorDialogNotifier.dispose();
    _showBackgroundDialogNotifier.dispose();
    _showEmotionDialogNotifier.dispose();
    _focusNode.removeListener(_focusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void showColorDialog(bool show) {
    _showColorDialogNotifier.value = show;
  }

  void showBackgroundDialog(bool show) {
    _showBackgroundDialogNotifier.value = show;
  }

  void showEmotionDialog(bool show) {
    _showEmotionDialogNotifier.value = show;
  }

  void insertTemplate(Template template) {
    var doc = Document.fromJson(jsonDecode(template.data));
    final int index = controller.selection.baseOffset;
    controller.skipRequestKeyboard = true;
    controller.replaceText(index, 0, doc.toDelta(), TextSelection.collapsed(offset: index + doc.length));
    backgroundController.changeBackground(BackgroundInfo(
      backgroundColor: template.backgroundColor,
      assetImage: template.backgroundImage == null ? null : AssetImage(template.backgroundImage!),
    ));
  }

  void _formatTitle() {
    controller.formatText(0, 1, Attribute.h2);
  }

  void _saveDocAsTemplate(BuildContext context) async {
    if (controller.document.isEmpty()) {
      DialogUtils.showToast(context, 'content is empty');
      return;
    }

    final delta = controller.document.toDelta();
    final bgInfo = backgroundController.backgroundInfo.value;
    final Color? bgColor;
    final String? bgImage;
    if (bgInfo == null) {
      bgColor = Colors.white;
      bgImage = null;
    } else {
      bgColor = bgInfo.backgroundColor;
      bgImage = bgInfo.assetImage?.assetName;
    }

    var res = await TemplateAddDialog.show(
      context,
      title: getFirstText(controller),
      content: DocUtils.getPlainTextFromDelta(delta),
      backgroundColor: bgColor,
      backgroundImage: bgImage,
    );

    // Navigator.pop(context, {'title': title, 'desc': _desc});
    if (res != null && res is Map) {
      var id = await TestSqliteHelper.instance.insertTemplate(
        Template(
          name: res['title'],
          desc: res['desc'],
          data: jsonEncode(delta.toJson()),
          backgroundColor: bgColor,
          backgroundImage: bgImage,
        ),
      );
      if (context.mounted) {
        if (id > 0) {
          DialogUtils.showToast(context, 'add template success');
        } else {
          DialogUtils.showToast(context, 'add template failed');
        }
      }
    }
  }

  void _saveDoc() async {
    if (controller.document.isEmpty()) {
      DialogUtils.showToast(context, 'content is empty');
      return;
    }

    final delta = controller.document.toDelta();
    final bgInfo = backgroundController.backgroundInfo.value;
    final Color? bgColor;
    final String? bgImage;
    if (bgInfo == null) {
      bgColor = Colors.white;
      bgImage = null;
    } else {
      bgColor = bgInfo.backgroundColor;
      bgImage = bgInfo.assetImage?.assetName;
    }

    // print('-----data:\n${jsonEncode(delta.toJson())}');

    DiaryRecord record = DiaryRecord(
      type: RecordType.diary,
      id: oldRecord?.id,
      content: jsonEncode(delta.toJson()),
      mood: _moodIndex,
      backgroundColor: bgColor,
      backgroundImage: bgImage,
      time: _time,
    );
    record.updateDiaryInfoByDelta(delta);
    print('----record: $record');
    if (record.id == null) {
      int res = await RecordManager().insertRecord(record);
      if (!mounted) {
        return;
      }
      if (res > 0) {
        // DialogUtils.showToast(context, 'save success');
        Navigator.pop(context, record.copyWith(id: res));
      } else {
        // DialogUtils.showToast(context, 'save failed');
        Navigator.pop(context);
      }
    } else {
      RecordManager().updateRecord(record);
      Navigator.pop(context, record);
    }
  }

  void _loadData() {
    if (oldRecord == null) {
      _time = DateTime.now();
      backgroundController = BackgroundController();
      _formatTitle();
    } else {
      // load background
      backgroundController = BackgroundController(
          info: BackgroundInfo(
        backgroundColor: oldRecord!.backgroundColor,
        assetImage: oldRecord!.backgroundImage == null ? null : AssetImage(oldRecord!.backgroundImage!),
      ));
      // load mood
      _moodIndex = oldRecord!.mood;
      // load time
      _time = oldRecord!.time;
      if (oldRecord!.content != null) {
        print('----load doc: ${oldRecord!.content}');
        controller.document = Document.fromJson(jsonDecode(oldRecord!.content!));
      }
    }
  }

  String getFirstText(QuillController controller) {
    if (controller.document.isEmpty()) {
      return '';
    }
    final firstLeaf = controller.document.root.children.first;
    if (firstLeaf is Line) {
      return firstLeaf.toPlainText();
    }
    return '';
  }

  void _handlePop(BuildContext context) async {
    final data = jsonEncode(controller.document.toDelta().toJson());
    if (_hasChanged(data)) {
      var res = await DialogUtils.showConfirmDialog(
        context,
        title: 'Save changes?',
        content: 'You have unsaved changes. Do you want to save them?',
        cancelText: 'Discard',
        confirmText: 'Save',
      );
      if (context.mounted) {
        if (res is int && res > 0) {
          print('----save doc: $data');
          _saveDoc();
        } else {
          Navigator.of(context).pop();
        }
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  bool _hasChanged(String data) {
    if (oldRecord == null) {
      return _moodIndex != null || !controller.document.isEmpty();
    }
    // todo
    return true;
  }

  @override
  Widget build(BuildContext context) {
    print('----build demo3');
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        _handlePop(context);
      },
      child: ToolBarDialogProvider(
          state: this,
          child: PageBackground(
            controller: backgroundController,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              iconTheme: TestConfiguration.toolbarIconStyle,
              forceMaterialTransparency: true,
              title: const Text('Edit'),
              actions: [
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  color: Colors.white,
                  offset: const Offset(-20, 36),
                  menuPadding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    // side: const BorderSide(color: TestColors.primary, width: 1),
                  ),
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        textStyle: const TextStyle(color: TestColors.black1),
                        onTap: () {
                          _saveDocAsTemplate(context);
                        },
                        child: const Text('save as template'),
                      ),
                      const PopupMenuItem(
                        child: Text('item2'),
                      ),
                    ];
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    _saveDoc();
                  },
                ),
              ],
            ),
            child: KeyboardVisibilityProvider(
              child: Stack(children: [
                Column(
                  children: [
                    EditHeader2(
                      time: _time,
                      onTimeChanged: (time) {
                        _time = time;
                      },
                      moodIndex: _moodIndex,
                      onEmotionChanged: (index) {
                        print('----emotion: $index');
                        _moodIndex = index;
                      },
                    ),
                    Container(height: 1, color: TestColors.greyDivider1),
                    Expanded(
                      child: QuillEditor.basic(
                        controller: controller,
                        focusNode: _focusNode,
                        configurations: const QuillEditorConfigurations(
                          padding: EdgeInsets.all(TestConfiguration.editorPadding),
                          placeholder: 'title',
                          // expands: true,
                          paintCursorAboveText: true,
                        ),
                      ),
                    ),
                    Toolbar(
                      controller: controller,
                      templateItemKey: _templateItemKey,
                    ),
                  ],
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _showColorDialogNotifier,
                  builder: (context, show, child) {
                    return show
                        ? SecondDialog(
                            title: 'Color',
                            child: ColorSelectDialog(
                              controller: controller,
                            ),
                            onDismiss: () {
                              showColorDialog(false);
                              KeyboardUtils.showKeyboardByChannel();
                            },
                          )
                        : const SizedBox.shrink();
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _showBackgroundDialogNotifier,
                  builder: (context, show, child) {
                    return show
                        ? SecondDialog(
                            title: 'Background',
                            child: BackgroundSelector(
                              backgroundInfo: backgroundController.backgroundInfo.value,
                              onBackgroundChanged: (info) {
                                backgroundController.changeBackground(info);
                              },
                            ),
                            onDismiss: () {
                              showBackgroundDialog(false);
                            },
                          )
                        : const SizedBox.shrink();
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _showEmotionDialogNotifier,
                  builder: (context, show, child) {
                    return show
                        ? SecondDialog(
                            title: 'Emotion',
                            child: EmotionSelector(
                              onEmotionSelected: (emoji) {
                                // showEmotionDialog(false);
                                final int index = controller.selection.baseOffset;
                                controller.skipRequestKeyboard = true;
                                controller.replaceText(
                                    index, 0, emoji, TextSelection.collapsed(offset: index + emoji.length));
                                KeyboardUtils.hideKeyboardByChannel();
                              },
                            ),
                            onDismiss: () {
                              showEmotionDialog(false);
                              // 显示键盘+光标
                              controller.replaceText(controller.selection.baseOffset, 0, '', null);
                              // KeyboardUtils.showKeyboard(context);
                              // KeyboardUtils.showKeyboardByChannel();
                            },
                          )
                        : const SizedBox.shrink();
                  },
                ),
                // if (_showColorDialog)
              ]),
            ),
          )),
    );
  }
}

class ToolBarDialogProvider extends InheritedWidget {
  final DiaryEditPageState state;

  const ToolBarDialogProvider({super.key, required this.state, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static DiaryEditPageState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ToolBarDialogProvider>()!.state;
  }
}
