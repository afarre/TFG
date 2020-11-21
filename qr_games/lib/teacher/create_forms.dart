import 'package:flutter/material.dart';

class CreateForms extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _CreateForms();

}

class _CreateForms extends State<CreateForms>{
  //final myController = TextEditingController();
  int _numQuestions = 1;

  @override
  Widget build(BuildContext context) {
    print("numQuestions first: $_numQuestions");
    List<Widget> _questions = new List.generate(_numQuestions, (int i) => new Question(_numQuestions));
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: Container(
        padding: new EdgeInsets.all(30.0),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            _displayTitle(),
            new Expanded(
              child: new ListView(
                children: _questions,
                scrollDirection: Axis.vertical,
              ),
            ),
            new FlatButton(
              onPressed: (){
                setState(() {
                  _numQuestions++;
                });
              },
              child: new Icon(Icons.add),
            ),
            SizedBox(height: 20),
            const Divider(
              color: Colors.black,
              height: 20,
              thickness: 1,
              indent: 20,
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
  Question(int numQuestions){
    print("numQuestions: $numQuestions");
    this._numQuestions = numQuestions;
  }

  @override
  State<StatefulWidget> createState() => new _Question(_numQuestions);
}

class _Question extends State<Question> {
  int _numQuestions;
  _Question(int numQuestions){
    this._numQuestions = numQuestions;
  }

  @override
  Widget build(BuildContext context) {
    return new TextFormField(
      maxLines: null,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Question title',
        isDense: true,
        prefixIcon:Text(_numQuestions.toString() + ". "),
        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}