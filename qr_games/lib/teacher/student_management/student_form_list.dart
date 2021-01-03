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
  List<String> _forms = [];

  @override
  void initState() {
    FileManager.listStudentForms(widget.student).then((value) => {
      value.forEach((student) {
        print("asasd " + student);
        setState(() {
          _forms = value;
        });
        print(_forms.length);
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
          title: Text('${widget.student}'),
        ),
        body: ListView.builder(
          itemCount: _forms.length,
          itemBuilder: (BuildContext context, int index){
            print("iterating on index: $index");
            return ListTile(
              leading: Icon(Icons.insert_drive_file),
              title: Text(_forms[index]),
              onTap: (){
                print("building form with student: ${widget.student}, and form: ${_forms[index]}");
                Navigator.push(context, MaterialPageRoute(builder: (context) => BuildStudentForm(widget.student, _forms[index])));
              },
            );
          },
        )
    );
  }
}