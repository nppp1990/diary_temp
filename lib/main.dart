import 'package:dribbble/clock/clock1/wheel/test_list_wheell.dart';
import 'package:dribbble/diary/button1.dart';
import 'package:dribbble/diary/data/bean/folder.dart';
import 'package:dribbble/diary/widgets/edit/edit_demo2.dart';
import 'package:dribbble/diary/widgets/edit/edit_demo3.dart';
import 'package:dribbble/diary/widgets/edit/toolbar/template/template_list.dart';
import 'package:dribbble/diary/widgets/emotion/edit_mood.dart';
import 'package:dribbble/diary/widgets/emotion/emotion_list.dart';
import 'package:dribbble/diary/widgets/folder/book_page.dart';
import 'package:dribbble/diary/widgets/folder/folders_page.dart';
import 'package:dribbble/diary/widgets/menu/home.dart';
import 'package:dribbble/diary/widgets/page_turn.dart';
import 'package:dribbble/diary/widgets/test_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'clock/clock2/index.dart';
import 'diary/common/test_colors.dart';
import 'diary/widgets/calendar/test_calendar.dart';
import 'diary/widgets/test_paint.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: TestColors.primary),
        useMaterial3: true,
      ),
      home: const DefaultTextStyle(
        style: TextStyle(color: TestColors.black1),
        child: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
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
    // ListItem('Clock1', (context) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => const ClockPage1()),
    //   );
    // }),
    // ListItem(
    //     'testWheel',
    //     (context) => Navigator.push(
    //           context,
    //           MaterialPageRoute(builder: (context) => const WheelExamplePage()),
    //         )),
    // ListItem(
    //     'testListWheel',
    //     (context) => Navigator.push(
    //           context,
    //           MaterialPageRoute(builder: (context) => const FixedExtentListPage()),
    //         )),
    // ListItem(
    //     'test circle list',
    //     (context) => Navigator.push(
    //           context,
    //           MaterialPageRoute(builder: (context) => const CircleListPage()),
    //         )),
    ListItem(
        'test circle loop list',
        (context) => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoopListPage()),
            )),
    ListItem('test picker',
        (context) => Navigator.push(context, MaterialPageRoute(builder: (context) => const ClockPage2()))),
    ListItem('turn page',
        (context) => Navigator.push(context, MaterialPageRoute(builder: (context) => const PageTurnEffect()))),
    ListItem('test card',
        (context) => Navigator.push(context, MaterialPageRoute(builder: (context) => const TestCardPage()))),
    ListItem('test path',
        (context) => Navigator.push(context, MaterialPageRoute(builder: (context) => const TestPaintPage()))),
    ListItem('test edit',
        (context) => Navigator.push(context, MaterialPageRoute(builder: (context) => const QuillEditorDemo()))),
    ListItem('test edit3', (context) async {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const TestEditDemo3()));
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          systemNavigationBarColor: Colors.white,
        ),
      );
    }),
    ListItem(
      'test emotion',
      (context) => Navigator.push(context, MaterialPageRoute(builder: (context) => const EmotionTestPage())),
    ),
    ListItem('test home', (context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }),
    ListItem('edit emotion', (context) {
      MoodDialog.showMoodDialog(context);
    }),
    ListItem('template list', (context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TemplateListPage()),
      );
    }),
    ListItem('test list', (context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TestListPage()),
      );
    }),
    ListItem('test list2', (context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TestListPage2()),
      );
    }),
    ListItem('test list3', (context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TestListPage3()),
      );
    }),
    ListItem('test folder', (context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FoldersPage()),
      );
    }),
    ListItem('test book', (context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiaryBook(
            folder: Folder(
              id: 1,
              name: 'Test Book',
              diaryCount: 0,
              backgroundImage: 'assets/images/bg_base1.png',
            ),
          ),
        ),
      );
    }),
    ListItem('test calendar', (context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TestCalendarPage(recordsMap: {})),
      );
    }),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _init();
    });
  }

  @override
  dispose() {
    print('----dispose');
    super.dispose();
  }

  _init() async {
    precacheImage(const AssetImage('assets/images/bg_base1.png'), context);
    precacheImage(const AssetImage('assets/images/bg_base2.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: SafeArea(
        child: ListView.builder(
            itemCount: test.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(test[index].key),
                onTap: () => test[index].onItemClick(context),
              );
            }),
      ),
    );
  }
}
