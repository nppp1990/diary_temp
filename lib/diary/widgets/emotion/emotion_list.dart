import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/widgets/bubble.dart';
import 'package:dribbble/diary/widgets/emotion/peace.dart';
import 'package:dribbble/diary/widgets/emotion/proud.dart';
import 'package:dribbble/diary/widgets/emotion/sad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              SizedBox(
                width: 300,
                height: 100,
                child: BubbleBorder(
                  triangleWidth: 20,
                  triangleHeight: 10,
                  triangleOffset: 20,
                  borderRadius: 12,
                  strokeWidth: 2,
                  strokeColor: Colors.blue,
                  child: Container(
                      color: Colors.yellow, child: const Center(child: Text('Bubble Border'))),
                ),
              ),
              const SizedBox(height: 40),
              const HappyEmotion(size: 100),
              const SizedBox(height: 20),
              const SadEmotion(size: 100),
              const SizedBox(height: 20),
              const AngryEmotion(size: 250),
              const SizedBox(height: 20),
              const PeaceEmotion(size: 100),
              const SizedBox(
                height: 20,
              ),
              const ProudEmotion(size: 100),
              ...TestConfiguration.moodImages.map((e) => SvgPicture.asset(
                    e,
                    width: 60,
                    height: 60,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: EmotionTestPage()));
}
