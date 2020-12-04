import 'package:flutter/material.dart';
import 'package:qr_games/model/form.dart';

class BuildForm extends StatefulWidget {
  FormModel _form;
  BuildForm(this._form);


  @override
  _BuildFormState createState() => _BuildFormState();
}

class _BuildFormState extends State<BuildForm> {
  int id = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Text(widget._form.title),
          Column(
            children:
            widget._form.questionList.map((data) => RadioListTile(
              title: Text("${data.question}"),
              groupValue: id,
              value: data.index,
              onChanged: (val) {
                setState(() {
                  id = data.index;
                  //radioItem = data.name ;
                });
              },
            )).toList(),
          ),
        ],
      ),
    );
  }
}
