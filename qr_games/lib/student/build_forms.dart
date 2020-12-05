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
  OptionModel selectedOptionModel;

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
            mapQuestions(),
          ),
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
            children: [
              Text(widget._form.questionList[i].question),
              mapOptions(widget._form.questionList[i].optionList)
            ],
          ),
        )
      );
    }
    return questionWidgetList;
  }

  mapOptions(List<OptionModel> optionList) {
    List<RadioListTile> optionWidgetList = [];
    for (OptionModel optionModel in optionList) {
      optionWidgetList.add(
        RadioListTile(
          value: optionModel,
          groupValue: selectedOptionModel,
          title: Text(optionModel.option),
          onChanged: (currentOption) {
            print("Current User $currentOption");
            setSelectedOption(currentOption);
          },
          selected: selectedOptionModel == optionModel,
          activeColor: Colors.green,
        ),
      );
    }
    return optionWidgetList;
  }

  void setSelectedOption(OptionModel optionModel) {
    setState(() {
      selectedOptionModel = optionModel;
    });
  }
}
