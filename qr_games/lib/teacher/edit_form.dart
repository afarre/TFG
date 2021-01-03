import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_games/common/shared_preferences.dart';
import 'package:qr_games/model/form.dart';


class EditForm extends StatefulWidget {
  final FormModel _form;
  EditForm(this._form);


  @override
  _EditFormState createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  List<int> selectedOption = [];
  List<TextEditingController> questionControllerList = [];
  List<TextEditingController> optionControllerList = [];

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
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.pop(context);
        },),
        title: Text('Editing: "${widget._form.title}"'),
      ),
      body: SingleChildScrollView (
        child: Column(
          children: <Widget>[
            Column(
              children: _mapQuestions(),
            ),
            RaisedButton(
              child: const Text('Save changes', style: TextStyle(fontSize: 20)),
              onPressed: () {
                List<QuestionModel> questionModelList = new List<QuestionModel>();
                for(var i = 0; i < widget._form.questionList.length; i++){
                  List<OptionModel> optionModelList = new List<OptionModel>();
                  for(var j = 0; j < widget._form.questionList[i].optionList.length; j++){
                    OptionModel optionModel = OptionModel(optionControllerList[i + j].text, j, false);
                    optionModelList.add(optionModel);
                  }
                  QuestionModel questionModel = QuestionModel(questionControllerList[i].text, optionModelList, i);
                  questionModelList.add(questionModel);
                }
                FormModel form = FormModel(widget._form.title, questionModelList);
                String json = jsonEncode(form);
                MySharedPreferences.setData(json, '#' + form.title);
                Navigator.pop(context);
              }
            )
          ],
        ),
      ),
    );
  }

  _mapQuestions() {
    List<Container> questionWidgetList = [];
    for (var i = 0; i < widget._form.questionList.length; i++){
      TextEditingController textEditingController = TextEditingController();
      textEditingController.text = widget._form.questionList[i].question;
      questionControllerList.add(textEditingController);
      questionWidgetList.add(
          new Container(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: textEditingController,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    prefixIcon: Text((i + 1).toString() + ". "),
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                ),
                Column(
                  children: _mapOptions(widget._form.questionList[i].optionList, widget._form.questionList[i].index),
                )
              ],
            ),
          )
      );
    }
    return questionWidgetList;
  }

   _mapOptions(List<OptionModel> optionList, int index) {
    List<ListTile> optionWidgetList = [];
    for (OptionModel optionModel in optionList) {
      TextEditingController textEditingController = TextEditingController();
      textEditingController.text = optionModel.option;
      optionControllerList.add(textEditingController);
      optionWidgetList.add(
        ListTile(
          title: TextFormField(
            controller: textEditingController,
            maxLines: null,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              prefixIcon: Text((optionModel.index + 1).toString() + ". "),
              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
            ),
          ),
        ),
      );
    }
    return optionWidgetList;
  }
}
