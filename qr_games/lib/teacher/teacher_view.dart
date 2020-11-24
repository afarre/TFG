import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:qr_games/teacher/endpoint_list.dart';
import 'package:qr_games/teacher/create_forms.dart';

class TeacherView extends StatefulWidget {
  _MyTeacherViewState createState() => _MyTeacherViewState();
}

class _MyTeacherViewState extends State<TeacherView>{
  List<EndpointData> endpointList = <EndpointData>[];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateForms()));
          },
        ),
        RaisedButton(
          child: const Text('Share forms', style: TextStyle(fontSize: 20)),
          onPressed: () {
            String a = Random().nextInt(100).toString();
            print("Sending $a");
            for (var endpoint in endpointList){
              Nearby().sendBytesPayload(endpoint.id, Uint8List.fromList(a.codeUnits));
            }
          },
        ),
        RaisedButton(
          child: const Text('Edit forms', style: TextStyle(fontSize: 20)),
          onPressed: () {},
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
          },
        ),
      ],
    );
  }
}