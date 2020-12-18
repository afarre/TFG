import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:qr_games/model/form.dart';


class BuildForm extends StatefulWidget {
  final FormModel _form;
  final String teacherId;
  BuildForm(this._form, this.teacherId);


  @override
  _BuildFormState createState() => _BuildFormState();
}

class _BuildFormState extends State<BuildForm> {
  int id = 0;
  List<int> selectedOption = [];

  @override
  void initState() {
    selectedOption = List.filled(widget._form.questionList.length, -1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Text(widget._form.title),
          Column(
            children: mapQuestions(),
          ),
          RaisedButton(
            child: const Text('Submit', style: TextStyle(fontSize: 20)),
            onPressed: () {
              for (var i = 0; i < selectedOption.length; i++){
                if(selectedOption[i] == -1){
                  continue;
                }
                widget._form.questionList[i].optionList[selectedOption[i]].selected = true;
              }
              print("[SUBMIT] sending msg to ${widget.teacherId}");
              String json = jsonEncode(widget._form);
              print("[SUBMIT] sending this form: $json");
              Nearby().sendBytesPayload(widget.teacherId, Uint8List.fromList(json.codeUnits));
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  mapQuestions() {
    List<Container> questionWidgetList = [];
    for (var i = 0; i < widget._form.questionList.length; i++){
      questionWidgetList.add(
        new Container(
          child: Column(
            children: <Widget>[
              Text((widget._form.questionList[i].index + 1).toString() + ". " + widget._form.questionList[i].question),
              Column(
                children: mapOptions(widget._form.questionList[i].optionList, widget._form.questionList[i].index),
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
          value: optionModel.index,
          groupValue: selectedOption[index],
          title: Text((optionModel.index + 1).toString() + ". " + optionModel.option),
          onChanged: (val) {
            print("Current User $val");
            setSelectedOption(val, index);
          },
          activeColor: Colors.green,
        ),
      );
    }
    return optionWidgetList;
  }

  void setSelectedOption(int val, int index) {
    setState(() {
      selectedOption[index] = val;
    });
  }
}
