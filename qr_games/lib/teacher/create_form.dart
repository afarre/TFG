import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_games/common/shared_preferences.dart';
import 'package:qr_games/model/form.dart';


class CreateForms extends StatefulWidget{
  _CreateForms _createForms;
  @override
  _CreateForms createState(){
    _createForms = _CreateForms();
    return _createForms;
  }

  FormModel getForm(){
    return _createForms.form;
  }
}

class _CreateForms extends State<CreateForms>{
  final _formKey = GlobalKey<FormState>();
  FormModel form;
  List<Question> _questions = [];
  final _myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _myController.dispose();
    super.dispose();
  }

  void _removeQuestion(Question question) {
    //setState(() {
    //TODO: Fix _questions.remove(question); not working properly
    //_questions.remove(question);
    _questions.removeLast();
    //});
  }

  void _addQuestion() {
    setState(() {
      Question question = Question(_removeQuestion, _questions.length);
      _questions.add(question);
      print("Adding question " + question.hashCode.toString());
    });
  }

  @override
  void initState() {
    _addQuestion(); //Initialize with 1 item
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < _questions.length; i++){
      print("Iterating on scaffold over: " + _questions[i].hashCode.toString());
      print("Son: ${_questions[i]._question.hashCode.toString()}");
    }
    return Scaffold(
      key: _formKey,
      resizeToAvoidBottomPadding: true,
      backgroundColor: Colors.white,
      body: Container(
        padding: new EdgeInsets.all(20.0),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            _displayTitle(),
            new Expanded(
              // height: 300,
              child: new ListView(
                children: <Widget>[
                  ..._questions,
                ],
                scrollDirection: Axis.vertical,
              ),
            ),
            Row(
              children: <Widget>[
                new FlatButton(
                  onPressed: () => _addQuestion(),
                  child: new Icon(Icons.playlist_add),
                ),
                /*
                new FlatButton(
                  onPressed: () {
                    print("Displaying question list items:");
                    for (var i = 0; i < _questions.length; i++){
                      print("Parent: " + _questions[i].hashCode.toString());
                      print("Son: ${_questions[i]._question.hashCode.toString()}");
                    }
                  },
                  child: new Icon(Icons.aspect_ratio),
                ),
                new FlatButton(
                  onPressed: () {
                    print("Set state");
                    setState(() {

                    });
                  },
                  child: new Icon(Icons.widgets),
                ),

                 */
              ],
            ),
            const Divider(
              color: Colors.black,
              height: 20,
              thickness: 1,
              indent: 0,
              endIndent: 0,
            ),
            Row(
              children: <Widget>[
                new Expanded(child: FlatButton(
                  onPressed: () {
                    //return to prev window
                    Navigator.pop(context);
                  },
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('Cancel', style: TextStyle(fontSize: 20.0)),
                ), flex: 2),
                new Expanded(child: RaisedButton(
                  child: Text('Create form', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    List<QuestionModel> questionModelList = new List<QuestionModel>();

                    for(var i = 0; i < _questions.length; i++){
                      List<OptionModel> optionModelList = new List<OptionModel>();
                      for(var j = 0; j < _questions[i]._optionList.length; j++){
                        OptionModel optionModel = OptionModel(_questions[i]._optionList[j].getOption(), j, false);
                        optionModelList.add(optionModel);
                      }
                      QuestionModel questionModel = QuestionModel(_questions[i].getQuestion(), optionModelList, i);
                      questionModelList.add(questionModel);
                    }
                    form = FormModel(_myController.text, questionModelList);
                    String json = jsonEncode(form);
                    MySharedPreferences.setData(json, '#' + form.title);
                    Navigator.pop(context);
                  },
                ), flex: 3)
              ],
            )
          ],
        ),
      ),
    );
  }

  _displayTitle(){
    return TextField(
      controller: _myController,
      maxLines: null,
      autofocus: true,
      decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Form title'
      ),
      style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold
      ),
    );
  }
}

class Question extends StatefulWidget {
  final int index;
  final Function(Question) removeQuestion;
  List<Option> _optionList = [];
  String _myQuestionStr;
  _Question _question;

  Question(this.removeQuestion, this.index);

  void remove(){
    print("Called remove on " + this.hashCode.toString());
    removeQuestion(this);
  }

  _Question createState(){
    _question = _Question(index, remove, _updateOptionList, _myQuestion);
    return _question;
  }

  void _updateOptionList(List<Option> optionList){
    _optionList = optionList;
    for(var i = 0; i < _optionList.length; i++){
      print("list size " + _optionList.length.toString() + " with component: " + _optionList[i].hashCode.toString());
    }
  }

  String getQuestion() {
    _question.getOption();
    return _myQuestionStr;
  }

  _myQuestion(String question) {
    this._myQuestionStr = question;
  }
}

class _Question extends State<Question> {
  final int questionIndex;
  final Function() remove;
  final Function(List<Option>) updateOptionList;
  final Function(String) myQuestion;
  final myController = TextEditingController();

  _Question(this.questionIndex, this.remove, this.updateOptionList, this.myQuestion);
  List<Option> _optionList = [];

  void _removeOption() {
    print("Removing last option");
    setState(() {
      _optionList.removeLast();
    });
  }

  void _addOption() {
    setState(() {
      Option option = Option(_optionList.length + 1);
      updateOptionList(_optionList);
      _optionList.add(option);
    });
  }

  @override
  void initState() {
    _addOption(); //Initialize with 1 item
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              //Text("q" + widget.hashCode.toString()),
              //Text("_q" + this.hashCode.toString()),
              Flexible(
                flex: 2,
                child: new TextFormField(
                  controller: myController,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Question title',
                    isDense: true,
                    prefixIcon:Text((questionIndex + 1).toString() + ". "),
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                ),
              ),
              new IconButton(
                  icon: new Icon(Icons.delete),
                  onPressed: (){
                    setState(() {
                      print("delete pressed");
                      remove();
                    });
                  }
              ),
            ],
          ),
          new ListView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              ..._optionList,
            ],
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
          ),
          Row(
            children: <Widget>[
              new FlatButton(
                onPressed: (){
                  setState(() {
                    _addOption();
                  });
                },
                child: new Icon(Icons.add),
              ),
              new FlatButton(
                onPressed: (){
                  setState(() {
                    _removeOption();
                  });
                },
                child: new Icon(Icons.remove),
              ),
            ],
          )
        ],
      ),
    );
  }

  void getOption() {
    myQuestion(myController.text);
  }
}


class Option extends StatefulWidget {
  final int _numOptions;
  _Option _option;
  String _myOption;

  Option(this._numOptions);

  _Option createState(){
    _option = _Option(_numOptions, myOption);
    return _option;
  }


  String getOption(){
    _option.getOption();
    return _myOption;
  }

  myOption(String option) {
    this._myOption = option;
  }
}

class _Option extends State<Option> {
  int _numOptions;
  final Function(String) _myOption;
  final _myController = TextEditingController();
  _Option(this._numOptions, this._myOption);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(left: 15),
      child: new TextFormField(
        controller: _myController,
        maxLines: null,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Option',
          isDense: true,
          prefixIcon:Text(_numOptions.toString() + ". "),
          prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }

  void getOption() {
    _myOption(_myController.text);
  }
}