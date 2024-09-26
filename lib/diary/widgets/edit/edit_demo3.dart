import 'dart:convert';

import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/data/bean/template.dart';
import 'package:dribbble/diary/data/sqlite_helper.dart';
import 'package:dribbble/diary/utils/dialog_utils.dart';
import 'package:dribbble/diary/utils/keyboard.dart';
import 'package:dribbble/diary/widgets/bg_page.dart';
import 'package:dribbble/diary/widgets/edit/header/edit_header.dart';
import 'package:dribbble/diary/widgets/edit/toolbar/background/background_selector.dart';
import 'package:dribbble/diary/widgets/edit/toolbar/template/template_item.dart';
import 'package:dribbble/diary/widgets/edit/toolbar/template/template_add_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

import 'toolbar/color/color_toolbar_item.dart';
import 'toolbar/emotion/emotion_selector.dart';
import 'toolbar/second_dialog.dart';
import 'toolbar/tool_bar.dart';

class TestEditDemo3 extends StatelessWidget {
  const TestEditDemo3({super.key});

  @override
  Widget build(BuildContext context) {
    return const TestEdit();
  }
}

class TestEdit extends StatefulWidget {
  const TestEdit({super.key});

  @override
  State<StatefulWidget> createState() => TestEditState();
}

class TestEditState extends State<TestEdit> {
  final QuillController controller = QuillController.basic();
  final FocusNode _focusNode = FocusNode();

  final BackgroundController backgroundController = BackgroundController();

  // late bool _showColorDialog;
  late ValueNotifier<bool> _showColorDialogNotifier;
  late ValueNotifier<bool> _showBackgroundDialogNotifier;
  late ValueNotifier<bool> _showEmotionDialogNotifier;

  final GlobalKey<ToolbarTemplateItemState> _templateItemKey = GlobalKey();
  bool _hasShowTemplateTips = false;

  @override
  void initState() {
    super.initState();
    // _showColorDialog = false;
    _showColorDialogNotifier = ValueNotifier<bool>(false);
    _showBackgroundDialogNotifier = ValueNotifier<bool>(false);
    _showEmotionDialogNotifier = ValueNotifier<bool>(false);
    _formatTitle();
    _focusNode.addListener(_focusChanged);
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

  void insertTemplate(String data) {
    var doc = Document.fromJson(jsonDecode(data));
    final int index = controller.selection.baseOffset;
    controller.skipRequestKeyboard = true;
    controller.replaceText(index, 0, doc.toDelta(), TextSelection.collapsed(offset: index + doc.length));
  }

  void _formatTitle() {
    // todo
    controller.formatText(0, 1, Attribute.h2);
  }

  void _saveDocAsTemplate(BuildContext context) async{
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
      content: _getPlainTextFromDelta(delta),
      backgroundColor: bgColor,
      backgroundImage: bgImage,
    );

    // Navigator.pop(context, {'title': title, 'desc': _desc});
    if (res != null && res is Map) {
      var id = await TestSqliteHelper.instance.createTemplate(
        Template(
          name: res['title'],
          desc: res['desc'],
          data:  jsonEncode(delta.toJson()),
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

  void _saveDoc() {
    final data = jsonEncode(controller.document.toDelta().toJson());

    // final allText = _getPlainTextFromDelta(delta);
    print('----data:\n $data');

    var test = jsonDecode(data);
    print('-----test: $test');
  }

  String _getPlainTextFromDelta(Delta delta) {
    String allText = '';
    for (final op in delta.operations) {
      if (op.isInsert) {
        allText += op.value;
      }
    }
    return allText;
  }

  String _getPlainTextFromJson(String deltaJson) {
    final delta = Delta.fromJson(jsonDecode(deltaJson));
    String allText = '';
    for (final op in delta.operations) {
      if (op.isInsert) {
        allText += op.value;
      }
    }
    return allText;
  }

  void _loadDoc(String? json) {
    if (json == null) {
      return;
    }
    controller.document = Document.fromJson(jsonDecode(json));
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

  @override
  Widget build(BuildContext context) {
    print('----build demo3');
    return ToolBarDialogProvider(
        state: this,
        child: PageBackground(
          controller: backgroundController,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: TestConfiguration.toolbarIconStyle,
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
                    date: DateTime.now(),
                    emotionIndex: null,
                    onDateChanged: (date) {
                      // year, month, day hh:mm
                      print('----date: $date');
                    },
                    onEmotionChanged: (index) {
                      print('----emotion: $index');
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
                            controller: backgroundController,
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
        ));
  }
}

class ToolBarDialogProvider extends InheritedWidget {
  final TestEditState state;

  const ToolBarDialogProvider({super.key, required this.state, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static TestEditState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ToolBarDialogProvider>()!.state;
  }
}
