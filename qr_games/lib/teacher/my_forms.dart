import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:qr_games/model/endpoint_data.dart';
import 'package:qr_games/common/shared_preferences.dart';
import 'package:qr_games/teacher/edit_form.dart';
import 'package:qr_games/model/form.dart';

class SavedForms extends StatefulWidget {
  final List<EndpointData> endpointList;
  SavedForms(this.endpointList);

  @override
  State<StatefulWidget> createState() => _SavedForms();
}

class _SavedForms extends State<SavedForms>{
  List<Card> myForms = [];
  static const DELETE = 0;
  static const SHARE = 1;

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
    MySharedPreferences.getKeys().then((result) {
      //result.forEach((element) { }); No se li pot fer un continue
      for(String e in result){
        if(e.contains("#")){
          e = e.replaceFirst("#", "");
        }else{
          continue;
        }

        Key key = Key(e);
        setState(() {
          myForms.add(
            Card(
              elevation: 5,
              key: key,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Text(e.toString()),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: (){
                      _editButtonPressed("#$e");
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: (){
                      _showAlertDialog(SHARE, e);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red.shade400,
                    ),
                    onPressed: (){
                      _showAlertDialog(DELETE, e);
                    },
                  )
                ],
              ),
            ),
          );
        });
      }
    });
  }

  _editButtonPressed(String formName) async {
    String str = await MySharedPreferences.getData(formName);
    Map<String, dynamic> decodedForm = jsonDecode(str);
    FormModel form = FormModel.fromJson(decodedForm);

    Navigator.push(context, MaterialPageRoute(builder: (context) => EditForm(form)));
  }

  _shareButtonPressed(String formName){
    MySharedPreferences.getData(formName).then((result) {
      String form;
      setState(() {
        if (result is String){
          form = result.toString(); //use toString to convert as String
        }
      });
      for (var endpoint in widget.endpointList){
        Nearby().sendBytesPayload(endpoint.id, Uint8List.fromList(form.codeUnits));
      }
    });
  }

  _deleteButtonPressed(String formName) {
    MySharedPreferences.deleteData("#" + formName);
    Key key = Key(formName);
    myForms.removeWhere((card) => card.key == key);
    setState(() {});
  }

  _showAlertDialog(int type, String formName) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );

    switch (type){
      case SHARE:
        Widget continueButton = FlatButton(
          child: Text("Share"),
          onPressed:  () {
            _shareButtonPressed("#$formName");
            Navigator.of(context).pop();
          },
        );
        // set up the AlertDialog
        AlertDialog alert = AlertDialog(
          title: Text("Share document"),
          content: Text("You are about to share this document: $formName.\n\nAre you sure?"),
          actions: [
            cancelButton,
            continueButton,
          ],
        );
        // show the dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
        break;
      case DELETE:
        Widget continueButton = FlatButton(
          child: Text("Delete", style: TextStyle(color: Colors.red),),
          onPressed:  () {
            _deleteButtonPressed("$formName");
            Navigator.of(context).pop();
          },
        );
        // set up the AlertDialog
        AlertDialog alert = AlertDialog(
          title: Text("Warning!"),
          content: Text("You are about to delete this form: $formName.\n\nAre you sure?"),
          actions: [
            cancelButton,
            continueButton,
          ],
        );
        // show the dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
        break;
    }

  }
}