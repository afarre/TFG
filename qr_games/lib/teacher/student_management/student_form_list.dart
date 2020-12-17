import 'package:flutter/material.dart';
import 'package:qr_games/common/file_manager.dart';
import 'package:qr_games/teacher/student_management/student_build_form.dart';

class StudentFormList extends StatefulWidget{
  final String student;
  StudentFormList(this.student);

  @override
  State<StatefulWidget> createState() => _StudentFormList();

}

class _StudentFormList extends State<StudentFormList> {
  List<String> forms = [];

  @override
  void initState() {
    FileManager.listStudentForms(widget.student).then((value) => {
      value.forEach((student) {
        print("asasd " + student);
        setState(() {
          forms = value;
        });
        print(forms.length);
      })
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
          itemCount: forms.length,
          itemBuilder: (BuildContext context, int index){
            print("iterating on index: $index");
            return ListTile(
              leading: Icon(Icons.insert_drive_file),
              title: Text(forms[index]),
              onTap: (){
                print("building form with student: ${widget.student}, and form: ${forms[index]}");
                Navigator.push(context, MaterialPageRoute(builder: (context) => BuildStudentForm(widget.student, forms[index])));
              },
            );
          },
        )
    );
  }
}