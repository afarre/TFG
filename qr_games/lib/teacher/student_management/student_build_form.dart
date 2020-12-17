import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_games/common/file_manager.dart';
import 'package:qr_games/model/form.dart';


class BuildStudentForm extends StatefulWidget {
  final String studentName;
  final String formName;
  BuildStudentForm(this.studentName, this.formName);

  @override
  State<StatefulWidget> createState() => _BuildStudentForm(studentName, formName);

}

class _BuildStudentForm extends State<BuildStudentForm>{
  FormModel form;
  final String studentName;
  final String formName;
  _BuildStudentForm(this.studentName, this.formName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: Colors.white,
      body: FutureBuilder<String>(
        future: getFutureData(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot){
          List<Widget> widgets;
          print("you flama too?");
          if (snapshot.hasData) {
            Map<String, dynamic> decodedForm = jsonDecode(snapshot.data);
            form = FormModel.fromJson(decodedForm);
            widgets = <Widget>[
              Column(
                  children: <Widget>[
                  Text(form.title),
                  Column(
                    children: mapQuestions(),
                  ),
                ],
              )
            ];
          }else{
            widgets = <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Loading form...'),
              )
            ];
          }
          return Column(
            children: widgets,
          );
        },
      ),
    );
  }

  Future<String> getFutureData() async {
    String value = await FileManager.getFileContent(widget.studentName, widget.formName);
    return value;
  }

  mapQuestions() {
    List<Container> questionWidgetList = [];
    for (var i = 0; i < form.questionList.length; i++){
      questionWidgetList.add(
          new Container(
            child: Column(
              children: <Widget>[
                Text((form.questionList[i].index + 1).toString() + ". " + form.questionList[i].question),
                Column(
                  children: mapOptions(form.questionList[i].optionList, form.questionList[i].index),
                )
              ],
            ),
          )
      );
    }
    return questionWidgetList;
  }

  mapOptions(List<OptionModel> optionList, int index) {
    List<RadioListTile> optionWidgetList = [];
    for (OptionModel optionModel in optionList) {
      optionWidgetList.add(
        RadioListTile(
          value: true,
          groupValue: optionModel.selected,
          title: Text((optionModel.index + 1).toString() + ". " + optionModel.option),
          onChanged: (val) {},
          activeColor: Colors.green,
          selectedTileColor: Colors.transparent,
          tileColor: Colors.transparent,
        ),
      );
    }
    return optionWidgetList;
  }

}