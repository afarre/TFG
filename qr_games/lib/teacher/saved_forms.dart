import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:qr_games/model/shared_preferences.dart';
import 'package:qr_games/teacher/endpoint_list.dart';

class SavedForms extends StatefulWidget {
  List<EndpointData> endpointList;
  SavedForms(this.endpointList);

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
    MySharedPreferences().getKeys().then((result) {
      result.forEach((element) {
        Key key = Key(element);
        print("displaying ${element.toString()}");
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
                      child: Text(element.toString()),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: (){
                      _editButtonPressed(element);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: (){
                      _shareButtonPressed(element);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red.shade400,
                    ),
                    onPressed: (){
                      _deleteButtonPressed(element);
                    },
                  )
                ],
              ),
            ),
          );
        });
      });
    });
  }

  _editButtonPressed(String element) {
    print("edit");
    //TODO: Edit existing forms
  }

  _shareButtonPressed(String element){
    print("Sending $element");

    MySharedPreferences().getForm(element).then((result) {
      String form;
      setState(() {
        if (result is String){
          print("result: $result");
          form = result.toString(); //use toString to convert as String
          print("result.toString ${result.toString()}");
        }
      });
      print("Sending $form");
      for (var endpoint in widget.endpointList){
        Nearby().sendBytesPayload(endpoint.id, Uint8List.fromList(form.codeUnits));
      }
    });
  }

  _deleteButtonPressed(String element) {
    MySharedPreferences().deleteForm(element);
    Key key = Key(element);
    myForms.removeWhere((card) => card.key == key);
    setState(() {});
  }
}