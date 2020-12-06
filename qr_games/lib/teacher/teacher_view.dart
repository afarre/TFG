import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:qr_games/teacher/create_forms.dart';
import 'package:qr_games/teacher/endpoint_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherView extends StatefulWidget {
  _MyTeacherViewState createState() => _MyTeacherViewState();
}

class _MyTeacherViewState extends State<TeacherView>{
  List<EndpointData> endpointList = <EndpointData>[];
  CreateForms createForms = CreateForms();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return GridView.count(
      crossAxisCount: 2 ,
      childAspectRatio: 3/2,
      padding: const EdgeInsets.all(15.0),
      mainAxisSpacing: 15.0,
      crossAxisSpacing: 30.0,
      children: <Widget>[
        RaisedButton(
          child: const Text('Create forms', style: TextStyle(fontSize: 20)),
          onPressed: () {
            print("Create form view selected");
            Navigator.push(context, MaterialPageRoute(builder: (context) => createForms));
          },
        ),
        RaisedButton(
          child: const Text('My forms', style: TextStyle(fontSize: 20)),
          onPressed: () {
            print("My forms");
            test().then((result) {
              String form;
              setState(() {
                if (result is String){
                  print("result: $result");
                  form = result.toString(); //use toString to convert as String
                  print("result.toString ${result.toString()}");
                }
              });
              print("Sending $form");
              for (var endpoint in endpointList){
                Nearby().sendBytesPayload(endpoint.id, Uint8List.fromList(form.codeUnits));
              }
            });
          },
        ),
        RaisedButton(
          child: const Text('Output saved form', style: TextStyle(fontSize: 20)),
          onPressed: () {
            test();
          },
        ),
        RaisedButton(
          child: const Text('Advertise device', style: TextStyle(fontSize: 20)),
          onPressed: () async {
            print("Advertise/view selected.");
            var navigationResult = await Navigator.push(context, MaterialPageRoute(builder: (context) => EndpointList(endpointList)));
            endpointList = navigationResult;
            Nearby().stopAdvertising();
            print("stopped advertising");
          }
        ),
        RaisedButton(
          child: const Text('Stop all endpoints', style: TextStyle(fontSize: 20)),
          onPressed: () {
            Nearby().stopAllEndpoints();
            endpointList = <EndpointData>[];
          },
        ),
      ],
    );
  }

  Future test() async{
    final prefs = await SharedPreferences.getInstance();
    final key = 'angel';
    final value = prefs.getString(key) ?? 0;
    print('read: $value');
    return value;
  }
}