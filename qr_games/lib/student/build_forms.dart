import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:qr_games/model/form.dart';


class BuildForm extends StatefulWidget {
  final FormModel form;
  final String teacherId;
  BuildForm(this.form, this.teacherId);


  @override
  _BuildFormState createState() => _BuildFormState();
}

class _BuildFormState extends State<BuildForm> {
  List<int> _selectedOption = [];

  @override
  void initState() {
    _selectedOption = List.filled(widget.form.questionList.length, -1);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.pop(context);
        },),
        title: Text(widget.form.title),
      ),
      resizeToAvoidBottomPadding: true,
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Column(
            children: mapQuestions(),
          ),
          RaisedButton(
            child: const Text('Submit', style: TextStyle(fontSize: 20)),
            onPressed: () {
              for (var i = 0; i < _selectedOption.length; i++){
                if(_selectedOption[i] == -1){
                  continue;
                }
                widget.form.questionList[i].optionList[_selectedOption[i]].selected = true;
              }
              print("[SUBMIT] sending msg to ${widget.teacherId}");
              String json = jsonEncode(widget.form);
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
    for (var i = 0; i < widget.form.questionList.length; i++){
      questionWidgetList.add(
        new Container(
          child: Column(
            children: <Widget>[
              Text((widget.form.questionList[i].index + 1).toString() + ". " + widget.form.questionList[i].question),
              Column(
                children: mapOptions(widget.form.questionList[i].optionList, widget.form.questionList[i].index),
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
          groupValue: _selectedOption[index],
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
      _selectedOption[index] = val;
    });
  }
}
