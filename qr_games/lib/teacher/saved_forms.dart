import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedForms extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SavedForms();
}

class _SavedForms extends State<SavedForms>{
  List<Card> myForms = [];

  @override
  void initState(){
    getKeys();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.pop(context);
        },),
        title: Text('My forms'),
      ),
      body: SingleChildScrollView(
        child:
          Container(
            padding: EdgeInsets.fromLTRB(10,10,10,0),
            width: double.maxFinite,
            child: Column(
              children: [
                ...myForms
              ],
            ) ,
          ),
      )
    );
  }

  getKeys() {
    getData().then((result) {
      result.forEach((element) {
        print("displaying ${element.toString()}");
        setState(() {
          myForms.add(
            Card(
              elevation: 5,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Text(element.toString()),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: _editButtonPressed,
                  ),
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: _shareButtonPressed,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red.shade400,
                    ),
                    onPressed: _deleteButtonPressed,
                  )
                ],
              ),
            ),
          );
        });
      });
    });
  }

  Future<Set<String>> getData() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getKeys();
    print("got ${value.length} results");
    return value;
  }


  _editButtonPressed() {
    print("edit");
  }

  _shareButtonPressed(){
    print("share");
  }

  _deleteButtonPressed(){
    print("delet this");
  }
}