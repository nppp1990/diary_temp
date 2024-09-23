import 'package:flutter/material.dart';
import 'package:star_menu/star_menu.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      drawer: const Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: Text('Item 1'),
            ),
            ListTile(
              title: Text('Item 2'),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Home Page'),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Add your onPressed code here!
      //   },
      //   backgroundColor: Colors.green,
      //   child: const Icon(Icons.add),
      // ),
      floatingActionButton: StarMenu(
        params: const StarMenuParameters(),
        onStateChanged: (state) => print('State changed: $state'),
        onItemTapped: (index, controller) {
          // here you can programmatically close the menu
          if (index == 7) {
            controller.closeMenu?.call();
          }
          // controller.closeMenu();
          // print('Menu item $index tapped');
        },
        items: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.looks_one)),
          IconButton(onPressed: (){}, icon: const Icon(Icons.looks_two)),
          IconButton(onPressed: (){}, icon: const Icon(Icons.looks_3)),
          IconButton(onPressed: (){}, icon: const Icon(Icons.looks_4)),
        ],
        child: FloatingActionButton(
          onPressed: () {
            print('FloatingActionButton tapped');
          },
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      //
    );
  }
}
