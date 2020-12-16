

import 'package:flutter/material.dart';
import 'package:qr_games/common/file_manager.dart';
import 'file:///C:/Users/angel/Desktop/4t/TFG/QRGames/Projecte/qr_games/lib/teacher/student_management/student_form_list.dart';

class StudentAnswerList extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _StudentAnswerList();

}

class _StudentAnswerList extends State<StudentAnswerList> {
  List<String> students = [];

  @override
  void initState() {
    FileManager.listDirContents(FileManager.DISPLAY_DIRECTORIES).then((value) => {
      value.forEach((student) {
        setState(() {
          students = value;
        });
        print(students.length);
      })
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
            Navigator.pop(context);
          },),
          title: Text('Student list'),
        ),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (BuildContext context, int index){
          print("iterating on index: $index");
          return ListTile(
            leading: Icon(Icons.folder),
            title: Text(students[index]),
            onTap: (){
              print("${students[index]} selected");
              Navigator.push(context, MaterialPageRoute(builder: (context) => StudentFormList(students[index])));
            },
          );
        },
      )
    );
  }
}