
import 'package:flutter/material.dart';
import 'package:qr_games/teacher/teacher_view.dart';

void main() => runApp(MyApp());


class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Nearby Connections example app'),
        ),
        body: getPage(_currentIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex, // this will be set when a new tab is tapped
          onTap: (value){
            setState(() { // Triggers the build method to be run again with the state that we pass in to it
              _currentIndex = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home),
              label: 'Teacher',
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.mail),
              label: 'Student',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings'
            )
          ],
        ),
      ),
    );
  }
  static fillSecondTab() {
    Scaffold(body: Container(
        padding: const EdgeInsets.all(32.0),
        alignment: Alignment.center,
        child: new Text("two")
    ),
    );
  }

  static fillThirdTab() {
    Scaffold(body: Container(
        padding: const EdgeInsets.all(32.0),
        alignment: Alignment.center,
        child: new Text("three")
    ),
    );
  }

  Widget getPage(int currentIndex) {
    if (currentIndex == 0) {
      return TeacherView();
    }
    if (currentIndex == 1) {
      return fillSecondTab();
    }
    if (currentIndex == 2) {
      return fillThirdTab();
    }
  }
}


