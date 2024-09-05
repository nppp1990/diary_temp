import 'package:dribbble/clock/clock1/index.dart';
import 'package:dribbble/clock/clock1/wheel/test_wheel.dart';
import 'package:dribbble/clock/clock1/wheel/test_list_wheell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'clock/clock2/index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

typedef OnItemClick = void Function(BuildContext context);

class ListItem {
  final String key;
  final OnItemClick onItemClick;

  ListItem(this.key, this.onItemClick);
}

class _MyHomePageState extends State<MyHomePage> {
  static List<ListItem> test = [
    ListItem('Clock1', (context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ClockPage1()),
      );
    }),
    ListItem(
        'testWheel',
        (context) => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WheelExamplePage()),
            )),
    ListItem(
        'testListWheel',
        (context) => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FixedExtentListPage()),
            )),
    ListItem(
        'test circle list',
        (context) => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CircleListPage()),
            )),
    ListItem(
        'test circle loop list',
        (context) => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoopListPage()),
            )),
    ListItem('testpicker', (context) => Navigator.push(context, MaterialPageRoute(builder: (context) => const ClockPage2()))),
    ListItem('todo6', (context) => debugPrint('todo6')),
    ListItem('todo7', (context) => debugPrint('todo7')),
    ListItem('todo8', (context) => debugPrint('todo8')),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
          itemCount: test.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(test[index].key),
              onTap: () => test[index].onItemClick(context),
            );
          }),
    );
  }
}
