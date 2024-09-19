import 'package:dribbble/diary/widgets/emotion/peace.dart';
import 'package:dribbble/diary/widgets/emotion/proud.dart';
import 'package:dribbble/diary/widgets/emotion/sad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'angry.dart';
import 'happy.dart';

class EmotionTestPage extends StatelessWidget {
  const EmotionTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion Test'),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: TextEditingController(

              ),
              contentInsertionConfiguration: ContentInsertionConfiguration(
                onContentInserted: (KeyboardInsertedContent value) {
                  print(value);
                },
                allowedMimeTypes: const <String>['image/*'],
              ),
              onChanged: (value) {
              },
              onTap: () async {
                var clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                print('---------clipboardData: ${clipboardData?.text}');
              },
            ),
            const SizedBox(height: 60),
            const HappyEmotion(size: 100),
            const SizedBox(height: 20),
            const SadEmotion(size: 100),
            const SizedBox(height: 20),
            const AngryEmotion(size: 100),
            const SizedBox(height: 20),
            const PeaceEmotion(size: 100),
            const SizedBox(
              height: 20,
            ),
            const ProudEmotion(size: 100),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: EmotionTestPage()));
}
