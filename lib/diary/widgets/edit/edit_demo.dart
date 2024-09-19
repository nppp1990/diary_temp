import 'package:flutter/material.dart';
import 'package:rich_editor/rich_editor.dart';

class EditDemo extends StatelessWidget {
  const EditDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Demo'),
      ),
      body: RichEditor(
        // key: keyEditor,
        value: 'initial html here',
        editorOptions: RichEditorOptions(
          placeholder: 'Start typing',
          // backgroundColor: Colors.blueGrey, // Editor's bg color
          // baseTextColor: Colors.white,
          // editor padding
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          // font name
          baseFontFamily: 'sans-serif',
          // Position of the editing bar (BarPosition.TOP or BarPosition.BOTTOM)
          barPosition: BarPosition.TOP,
        ),
        // You can return a Link (maybe you need to upload the image to your
        // storage before displaying in the editor or you can also use base64
        getImageUrl: (image) {
          // String link = 'https://avatars.githubusercontent.com/u/24323581?v=4';
          // String base64 = base64Encode(image.readAsBytesSync());
          // String base64String = 'data:image/png;base64, $base64';
          // return base64String;
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: EditDemo()));
}
