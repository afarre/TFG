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
  List<int> selectedOption = [];

  @override
  void initState() {
    selectedOption = new List(widget._form.questionList.length);
    List.filled(widget._form.questionList.length, 0);
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
              //TODO: contestar el questionari ple
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
