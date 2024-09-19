import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/utils/keyboard.dart';
import 'package:dribbble/diary/widgets/bg_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'toolbar/color/color_toolbar_item.dart';
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

  @override
  void initState() {
    super.initState();
    // _showColorDialog = false;
    _showColorDialogNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _showColorDialogNotifier.dispose();
    super.dispose();
  }

  void showColorDialog(bool show) {
    _showColorDialogNotifier.value = show;
    // setState(() {
    //   _showColorDialog = show;
    // });
  }

  void hideDialog() {
    _showColorDialogNotifier.value = false;
    // setState(() {
    //   _showColorDialog = false;
    // });
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
                      height: 100,
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                            backgroundController.changeBackground(
                              assetImage: const AssetImage('assets/images/bg_base1.png'),
                            );
                            // showColorDialog(!_showColorDialog);
                          },
                          child: const Center(child: Text('Change Background'))),
                    ),
                    Expanded(
                      child: QuillEditor.basic(
                        controller: controller,
                        configurations: const QuillEditorConfigurations(
                          padding: EdgeInsets.all(TestConfiguration.editorPadding),
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
                              KeyboardUtils.showKeyboardByChannel();
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
