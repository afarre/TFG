import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:qr_games/model/form.dart';


class EditForm extends StatefulWidget {
  final FormModel _form;
  EditForm(this._form);


  @override
  _EditFormState createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
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
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.pop(context);
        },),
        title: Text('Editing: "${widget._form.title}"'),
      ),
      body: Column(
        children: <Widget>[
          Column(
            children: _mapQuestions(),
          ),
          RaisedButton(
            child: const Text('Save changes', style: TextStyle(fontSize: 20)),
            onPressed: () {
              //TODO: update form's data
              Navigator.pop(context);
            }
          )
        ],
      ),
    );
  }

  _mapQuestions() {
    List<Container> questionWidgetList = [];
    for (var i = 0; i < widget._form.questionList.length; i++){
      questionWidgetList.add(
          new Container(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: TextEditingController(text: widget._form.questionList[i].question),
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
      optionWidgetList.add(
        ListTile(
          title: TextFormField(
            controller: TextEditingController(text: optionModel.option),
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
