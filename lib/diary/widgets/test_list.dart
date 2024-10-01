import 'package:dribbble/diary/widgets/list/diary_list.dart';
import 'package:flutter/material.dart';

import 'list/diary_list2.dart';
import 'list/diary_list3.dart';

class TestListPage extends StatelessWidget {
  const TestListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test List'),
      ),
      body: const Center(
        child: TestListView(),
      )
    );
  }
}

class TestListPage2 extends StatelessWidget {
  const TestListPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Test List2'),
        ),
        body: const Center(
          child: TestListView2(),
        )
    );
  }
}

class TestListPage3 extends StatelessWidget {
  const TestListPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Test List3'),
        ),
        body: const Center(
          child: TestListView3(),
        )
    );
  }
}
