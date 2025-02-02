
import 'package:flutter/material.dart';
import 'package:qr_games/common/app_icons.dart';
import 'package:qr_games/settings/settings_view.dart';
import 'package:qr_games/student/student_view.dart';
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
          title: const Text('QR Games'),
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
              icon: new Icon(MyFlutterApp.teacher),
              label: 'Teacher',
            ),
            BottomNavigationBarItem(
              icon: new Icon(MyFlutterApp.student),
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

  Widget getPage(int currentIndex) {
    if (currentIndex == 0) {
      return TeacherView();
    }
    if (currentIndex == 1) {
      return StudentView();
    }
    if (currentIndex == 2) {
      return SettingsView();
    }
    return null;
  }
}


