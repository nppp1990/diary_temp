import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/translations.dart';

class QuillEditorDemo extends StatefulWidget {
  const QuillEditorDemo({super.key});

  @override
  State<StatefulWidget> createState() => _QuillEditorDemoState();
}

class _QuillEditorDemoState extends State<QuillEditorDemo> {
  final QuillController _controller = QuillController.basic();

  Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quill Editor Demo'),
      ),
      body: Column(
        children: [
          FlutterQuillLocalizationsWidget(
            child:  TestFontFamilyButton(
              controller: _controller,
            ),
          ),

          QuillSimpleToolbar(
            controller: _controller,
            configurations: const QuillSimpleToolbarConfigurations(
              showDirection: true,
            ),
          ),
          Expanded(
            child: QuillEditor.basic(
              controller: _controller,
              configurations: QuillEditorConfigurations(
                onImagePaste: (Uint8List imageBytes) async {
                  print('-------onImagePaste: ${imageBytes.length}');
                  return null;
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

// class TestFontFamilyButtonOptions extends QuillToolbarBaseButtonOptions<TestFontFamilyButtonOptions, QuillToolbarFontFamilyButtonExtraOptions> {
//   const TestFontFamilyButtonOptions({
//     // super.iconData,
//     // super.afterButtonPressed,
//     // super.tooltip,
//     // super.iconTheme,
//     // super.childBuilder,
//     // this.onSelected,
//     // this.padding,
//     // this.style,
//     // this.width,
//     // this.initialValue,
//     // this.labelOverflow = TextOverflow.visible,
//     // this.overrideTooltipByFontFamily = false,
//     // this.itemHeight,
//     // this.itemPadding,
//     // this.defaultItemColor = Colors.red,
//     // this.renderFontFamilies = true,
//     // super.iconSize,
//     // super.iconButtonFactor,
//     // this.defaultDisplayText,
//   });

// }

class TestFontFamilyButton extends StatelessWidget {
  final QuillController controller;

  const TestFontFamilyButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return QuillToolbarFontFamilyButton(
      controller: controller,
      options: QuillToolbarFontFamilyButtonOptions(
        afterButtonPressed: () {
          print('-------afterButtonPressed');
          // controller.formatSelection(Attribute.font.key, 'Arial');
        },

        childBuilder:
            (QuillToolbarFontFamilyButtonOptions options, QuillToolbarFontFamilyButtonExtraOptions extraOptions) {
          return InkWell(
            onTap: () {
              extraOptions.onPressed?.call();
            },
            child: Container(
              width: 200,
              height: 30,
              color: Colors.red,
              child: Center(child: Text(extraOptions.currentValue)),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: QuillEditorDemo()));
}
