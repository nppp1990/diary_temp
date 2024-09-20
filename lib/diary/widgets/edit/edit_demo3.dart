import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/utils/keyboard.dart';
import 'package:dribbble/diary/widgets/bg_page.dart';
import 'package:dribbble/diary/widgets/edit/toolbar/background/background_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_quill/flutter_quill.dart';

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
  final BackgroundController backgroundController = BackgroundController();

  // late bool _showColorDialog;
  late ValueNotifier<bool> _showColorDialogNotifier;
  late ValueNotifier<bool> _showBackgroundDialogNotifier;
  late ValueNotifier<bool> _showEmotionDialogNotifier;

  @override
  void initState() {
    super.initState();
    // _showColorDialog = false;
    _showColorDialogNotifier = ValueNotifier<bool>(false);
    _showBackgroundDialogNotifier = ValueNotifier<bool>(false);
    _showEmotionDialogNotifier = ValueNotifier<bool>(false);
    _formatTitle();
  }

  @override
  void dispose() {
    _showColorDialogNotifier.dispose();
    _showBackgroundDialogNotifier.dispose();
    _showEmotionDialogNotifier.dispose();
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


  @override
  Widget build(BuildContext context) {
    print('----build demo3');
    return ToolBarDialogProvider(
      state: this,
      child: PageBackground(
          controller: backgroundController,
          child: SafeArea(
            child: KeyboardVisibilityProvider(
              child: Stack(children: [
                Column(
                  children: [
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                            // showColorDialog(!_showColorDialog);
                            final int index = controller.selection.baseOffset;
                            // final length = controller.selection.extentOffset - index;
                            // controller.replaceText(index, length, BlockEmbed.image('assets/images/ic_emotion1.png'), null);
                            controller.replaceText(index, 0, 'test insert', null);
                          },
                          child: const Center(child: Text('test1'))),
                    ),
                    // SizedBox(
                    //   height: 60,
                    //   width: double.infinity,
                    //   child: ElevatedButton(
                    //       onPressed: () {
                    //         // showColorDialog(!_showColorDialog);
                    //       },
                    //       child: const Center(child: Text('test2'))),
                    // ),
                    // SizedBox(
                    //   height: 60,
                    //   width: double.infinity,
                    //   child: ElevatedButton(
                    //       onPressed: () {
                    //         // showColorDialog(!_showColorDialog);
                    //       },
                    //       child: const Center(child: Text('test3'))),
                    // ),
                    Expanded(
                      child: QuillEditor.basic(
                        controller: controller,
                        configurations: const QuillEditorConfigurations(
                          padding: EdgeInsets.all(TestConfiguration.editorPadding),
                          placeholder: 'title',
                          // expands: true,
                          paintCursorAboveText: true,


                        ),
                      ),
                    ),
                    Toolbar(controller: controller),
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
                                controller.replaceText(index, 0, emoji, TextSelection.collapsed(offset: index + emoji.length));
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
  final TestEditState state;

  const ToolBarDialogProvider({super.key, required this.state, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static TestEditState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ToolBarDialogProvider>()!.state;
  }
}
