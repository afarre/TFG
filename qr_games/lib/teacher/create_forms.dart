import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_games/model/form.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  void removeQuestion(index) {
    print("Removing question " + index.hashCode.toString());
    setState(() {
      _questions.remove(index);
    });
  }

  void addQuestion() {
    setState(() {
      Question question = Question(removeQuestion, _questions.length);
      _questions.add(question);
      print("Adding question " + question.hashCode.toString());
    });
  }

  @override
  void initState() {
    addQuestion(); //Initialize with 1 item
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < _questions.length; i++){
      print("Iterating on scaffold over: " + _questions[i].hashCode.toString());
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
                  onPressed: () => addQuestion(),
                  child: new Icon(Icons.ac_unit),
                ),
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
                      print("For option: " + _questions[i].getQuestion());
                      List<OptionModel> optionModelList = new List<OptionModel>();
                      for(var j = 0; j < _questions[i]._optionList.length; j++){
                        print("\tOption: " + _questions[i]._optionList[j].getOption());
                        OptionModel optionModel = OptionModel(_questions[i]._optionList[j].getOption(), j, false);
                        optionModelList.add(optionModel);
                      }
                      QuestionModel questionModel = QuestionModel(_questions[i].getQuestion(), optionModelList, i);
                      questionModelList.add(questionModel);
                    }
                    form = FormModel(myController.text, questionModelList);
                    String json = jsonEncode(form);
                    saveForm(json, form.title);
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
      controller: myController,
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

  void saveForm(String json, String title) async{
    final prefs = await SharedPreferences.getInstance();
    final key = title;
    final value = json;
    prefs.setString(key, value);
    print('saved $value');
  }
}

class Question extends StatefulWidget {
  final int index;
  final Function(Question) removeQuestion;
  List<Option> _optionList = [];
  String _myQuestion;
  _Question _question;

  Question(this.removeQuestion, this.index);

  void remove(){
    print("Called remove on " + this.hashCode.toString());
    removeQuestion(this);
  }

  _Question createState(){
    _question = _Question(index, remove, updateOptionList, myQuestion);
    return _question;
  }

  void updateOptionList(List<Option> optionList){
    _optionList = optionList;
    for(var i = 0; i < _optionList.length; i++){
      print("list size " + _optionList.length.toString() + " with component: " + _optionList[i].hashCode.toString());
    }
  }

  String getQuestion() {
    _question.getOption();
    return _myQuestion;
  }

  myQuestion(String question) {
    this._myQuestion = question;
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

  void removeOption() {
    print("Removing last option");
    setState(() {
      _optionList.removeLast();
    });
  }

  void addOption() {
    setState(() {
      Option option = Option(_optionList.length + 1);
      updateOptionList(_optionList);
      _optionList.add(option);
      print("Adding option " + option.hashCode.toString());
    });
  }

  @override
  void initState() {
    addOption(); //Initialize with 1 item
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.accents.elementAt(3 * questionIndex),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(this.hashCode.toString()),
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
                  print("delete pressed");
                  remove();
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
                    addOption();
                  });
                },
                child: new Icon(Icons.add),
              ),
              new FlatButton(
                onPressed: (){
                  setState(() {
                    removeOption();
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
  final Function(String) myOption;
  final myController = TextEditingController();
  _Option(this._numOptions, this.myOption);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(left: 15),
      child: new TextFormField(
        controller: myController,
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
    myOption(myController.text);
  }
}