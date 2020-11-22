import 'package:flutter/material.dart';

class CreateForms extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _CreateForms();

}

class _CreateForms extends State<CreateForms>{
  //final myController = TextEditingController();
  static int _numQuestions = 1;
  List<Widget> _questions = new List.generate(_numQuestions, (int i) => new Question(_numQuestions, i));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                children: _questions,
                scrollDirection: Axis.vertical,
              ),
            ),
            Row(
              children: <Widget>[
                new FlatButton(
                  onPressed: (){
                    setState(() {
                      _numQuestions++;
                    });
                  },
                  child: new Icon(Icons.add),
                ),
                new FlatButton(
                  onPressed: (){
                    setState(() {
                      _numQuestions--;
                    });
                  },
                  child: new Icon(Icons.remove),
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
                    //return to prev window with task text
                    Navigator.pop(context/*, myController.text*/);
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
  int _numQuestions;
  int _myIndex;
  Question(int numQuestions, int myIndex){
    this._numQuestions = numQuestions;
    this._myIndex = myIndex;
  }

  @override
  State<StatefulWidget> createState() => new _Question(_numQuestions, _myIndex);
}

class _Question extends State<Question> {
  int _numOptions = 1;
  int _numQuestions;
  int _myIndex;
  _Question(int numQuestions, int myIndex){
    this._numQuestions = numQuestions;
    this._myIndex = myIndex;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _options = new List.generate(_numOptions, (int i) => new Options(_numOptions));
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                flex: 2,
                child: new TextFormField(
                  maxLines: null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Question title',
                    isDense: true,
                    prefixIcon:Text(_numQuestions.toString() + ". "),
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                ),
              ),
              new IconButton(
                icon: new Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _CreateForms()._questions.removeAt(_myIndex);
                  });
                },
              ),
            ],
          ),
          new ListView(
            physics: NeverScrollableScrollPhysics(),
            children: _options,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
          ),
          Row(
            children: <Widget>[
              new FlatButton(
                onPressed: (){
                  setState(() {
                    _numOptions++;
                  });
                },
                child: new Icon(Icons.add),
              ),
              new FlatButton(
                onPressed: (){
                  setState(() {
                    _numOptions--;
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
}


class Options extends StatefulWidget {
  int _numOptions;

  Options(int numOptions){
    this._numOptions = numOptions;
  }

  @override
  State<StatefulWidget> createState() => new _Options(_numOptions);
}

class _Options extends State<Options> {
  int _numOptions;
  _Options(int numOptions){
    this._numOptions = numOptions;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(left: 15),
      child: new TextFormField(
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
}