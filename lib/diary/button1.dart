import 'dart:math';
import 'dart:ui';

import 'package:dribbble/diary/widgets/card.dart';
import 'package:dribbble/diary/widgets/coli.dart';
import 'package:dribbble/diary/widgets/cord.dart';
import 'package:flutter/material.dart';

class TestLayout extends StatelessWidget {
  const TestLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  RotateCard(
                    angle: -3 / 180 * pi,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const MemphisCard(child: TestChild()),
                  ),
                  const SizedBox(height: 20),
                  const MemphisCard(child: TestChild()),
                  const SizedBox(height: 20),
                  // const Coil(),
                  const ColiContainer(
                    coliPaddingLeft: 20,
                    height: 580,
                  ),
                  const SizedBox(height: 120),
                  const DashOffsetCard(
                    offset: Offset(5, 5),
                    borderRadius: 40,
                    child: MemphisCard(child: TestChild()),
                  ),
                  const SizedBox(height: 20),
                  OffsetCard(
                    cardHeight: 100,
                    offset: const Offset(5, 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const MemphisCard(child: TestChild()),
                  ),
                  const SizedBox(height: 20),
                  const DashOffsetCard(
                    offset: Offset(5, 5),
                    borderRadius: 40,
                    child: MemphisCard(child: TestChild()),
                  ),
                  const SizedBox(height: 20),
                  const MemphisCard(
                      child: TestChild(
                    index: 10,
                  )),
                  const SizedBox(height: 20),
                  const DashOffsetCard(
                    offset: Offset(5, 5),
                    borderRadius: 40,
                    child: MemphisCard(
                        child: TestChild(
                      index: 11,
                    )),
                  ),
                  const SizedBox(height: 20),
                  const MemphisCard(
                      child: TestChild(
                    index: 12,
                  )),
                ],
              ),
              const Positioned(
                  left: 30,
                  top: 40 + 100 - 15,
                  child: SizedBox(
                    height: 100,
                    width: 30,
                    child: CordLock(lockRadius: 10, lineWidthRatio: 0.3,),
                  ))
            ],
          )),
    );
  }
}

class TestChild extends StatelessWidget {
  final int index;

  const TestChild({super.key, this.index = 100});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Memphis Style $index',
        style: const TextStyle(
          fontSize: 24,
          color: Colors.yellow,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class MemphisCard extends StatelessWidget {
  final Widget child;

  const MemphisCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    Decoration decoration = BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.black, width: 2),
      borderRadius: BorderRadius.circular(40),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 16,
          offset: Offset(4, 4),
        ),
      ],
    );
    return Container(
      height: 100,
      decoration: decoration,
      child: child,
    );
  }
}

class TestCardPage extends StatelessWidget {
  const TestCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TestLayout(),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Memphis Style Button')),
        body: const TestLayout(),
      ),
    );
  }
}
