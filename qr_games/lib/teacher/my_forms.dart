import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:qr_games/model/endpoint_data.dart';

import 'file:///C:/Users/angel/Desktop/4t/TFG/QRGames/Projecte/qr_games/lib/common/shared_preferences.dart';

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
    MySharedPreferences.getKeys().then((result) {
      //result.forEach((element) { }); No se li pot fer un continue
      for(String e in result){
        if(e.contains("#")){
          e = e.replaceFirst("#", "");
        }else{
          continue;
        }

        Key key = Key(e);
        print("displaying ${e.toString()}");
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
                      _shareButtonPressed("#$e");
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red.shade400,
                    ),
                    onPressed: (){
                      _deleteButtonPressed("$e");
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

  _editButtonPressed(String formName) {
    print("edit");
    //TODO: Edit existing forms
  }

  _shareButtonPressed(String formName){
    print("[SHARED_BUTTON_PRESSED] Sending $formName");

    MySharedPreferences.getData(formName).then((result) {
      String form;
      setState(() {
        if (result is String){
          form = result.toString(); //use toString to convert as String
        }
      });
      print("[SHARED_BUTTON_PRESSED] Sending this form: $form");
      for (var endpoint in widget.endpointList){
        Nearby().sendBytesPayload(endpoint.id, Uint8List.fromList(form.codeUnits));
      }
    });
  }

  _deleteButtonPressed(String formName) {
    MySharedPreferences.deleteData(formName);
    Key key = Key(formName);
    myForms.removeWhere((card) => card.key == key);
    setState(() {});
  }
}