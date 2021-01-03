import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_games/common/file_manager.dart';
import 'package:qr_games/model/form.dart';


class BuildStudentForm extends StatefulWidget {
  final String studentName;
  final String formName;
  BuildStudentForm(this.studentName, this.formName);

  @override
  State<StatefulWidget> createState() => _BuildStudentForm();

}

class _BuildStudentForm extends State<BuildStudentForm>{
  FormModel _form;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.pop(context);
        },),
        title: Text('${widget.studentName} > ${widget.formName.replaceFirst(".json", "")}'),
      ),
      resizeToAvoidBottomPadding: true,
      backgroundColor: Colors.white,
      body: FutureBuilder<String>(
        future: _getFutureData(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot){
          List<Widget> widgets;
          print("you flama too?");
          if (snapshot.hasData) {
            Map<String, dynamic> decodedForm = jsonDecode(snapshot.data);
            _form = FormModel.fromJson(decodedForm);
            widgets = <Widget>[
              Column(
                  children: <Widget>[
                  Column(
                    children: _mapQuestions(),
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

  Future<String> _getFutureData() async {
    String value = await FileManager.getFileContent(widget.studentName, widget.formName);
    return value;
  }

  _mapQuestions() {
    List<Container> questionWidgetList = [];
    for (var i = 0; i < _form.questionList.length; i++){
      questionWidgetList.add(
          new Container(
            child: Column(
              children: <Widget>[
                Text((_form.questionList[i].index + 1).toString() + ". " + _form.questionList[i].question),
                Column(
                  children: _mapOptions(_form.questionList[i].optionList, _form.questionList[i].index),
                )
              ],
            ),
          )
      );
    }
    return questionWidgetList;
  }

  _mapOptions(List<OptionModel> optionList, int index) {
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