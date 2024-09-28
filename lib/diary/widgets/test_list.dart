import 'package:dribbble/diary/widgets/list/diary_list.dart';
import 'package:flutter/material.dart';

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

class _TestListItem extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _TestListItem({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    print('------_TestListItem build: $title');
    return ListTile(
      title: Text(title),
      onTap: onTap,
    );
  }
}