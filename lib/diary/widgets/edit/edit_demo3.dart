import 'dart:convert';

import 'package:dribbble/diary/bean/template_add_dialog.dart';
import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/utils/keyboard.dart';
import 'package:dribbble/diary/widgets/bg_page.dart';
import 'package:dribbble/diary/widgets/edit/header/edit_header.dart';
import 'package:dribbble/diary/widgets/edit/toolbar/background/background_selector.dart';
import 'package:dribbble/diary/widgets/edit/toolbar/template/template_item.dart';
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

  void _formatTitle() {
    // todo
    controller.formatText(0, 1, Attribute.h2);
  }

  String? _testJson = null;

  void _saveDoc() {
    // controller.getPlainText();

    final delta = controller.document.toDelta();
    final json = jsonEncode(delta.toJson());

    String allText = '';

    for (final op in delta.operations) {
      if (op.isInsert) {
        allText += op.value;
        print('----insert: ${op.value}');
      } else {
        print('----retain: ${op.length}');
      }
    }

    print('----allText: $allText');

    final text = controller.getPlainText();
    print('----text: $text');

    print('----json: $json');

    print('----first text: ${getFirstText(controller)}');
    _testJson = json;
    TemplateAddDialog.show(
      context,
      color: Colors.yellow,
      content: allText,
      title: getFirstText(controller),
    );
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
            iconTheme: const IconThemeData(color: TestColors.black1, size: 28),
            title: const Text('Edit'),
            actions: [
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      onTap: () {
                        // Navigator.pop(context);
                      },
                      child: const Text('item1'),
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
                      _saveDoc();
                    },
                    onEmotionChanged: (index) {
                      print('----emotion: $index');
                      _loadDoc(_testJson);
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
