import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:qr_games/teacher/endpoint_list.dart';
import 'package:qr_games/teacher/func.dart';

class TeacherView extends StatelessWidget {
  EndpointList endpointList;
  TeacherView(EndpointList endpointList){
    this.endpointList = endpointList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: View(endpointList));
  }
}

class View extends StatelessWidget {
  final Strategy strategy = Strategy.P2P_STAR;
  String cId = "0"; //currently connected device ID
  File tempFile; //reference to the file currently being transferred
  Map<int, String> map = Map();

  EndpointList endpointList;
  View(EndpointList endpointList){
    this.endpointList = endpointList;
  }

  @override
  Widget build(BuildContext context) {
    Asd asd = new Asd(context, endpointList);
    return GridView.count(
      crossAxisCount: 2 ,
      childAspectRatio: 3/2,
      padding: const EdgeInsets.all(15.0),
      mainAxisSpacing: 15.0,
      crossAxisSpacing: 30.0,
      children: <Widget>[
        RaisedButton(
          child: const Text('Create forms', style: TextStyle(fontSize: 20)),
          onPressed: () {},
        ),
        RaisedButton(
          child: const Text('Share forms', style: TextStyle(fontSize: 20)),
          onPressed: () {},
        ),
        RaisedButton(
          child: const Text('Edit forms', style: TextStyle(fontSize: 20)),
          onPressed: () {},
        ),
        RaisedButton(
          child: const Text('View connected devices', style: TextStyle(fontSize: 20)),
          onPressed: () {
            print("View connected");
            Navigator.pushNamed(context, '/endpoint_list');
          },
        ),
        RaisedButton(
          child: const Text('Advertise device', style: TextStyle(fontSize: 20)),
          onPressed: () async {
            try {
              bool a = await Nearby().startAdvertising(
                "teacher",
                strategy,
                onConnectionInitiated: asd.onConnectionInit,
                onConnectionResult: (id, status) {
                  asd.showSnackbar(status);
                },
                onDisconnected: (id) {
                  asd.showSnackbar("Disconnected: " + id);
                },
              );
              asd.showSnackbar("ADVERTISING: " + a.toString());
            } catch (exception) {
              asd.showSnackbar(exception);
            }
          },
        ),
      ],
    );
  }
}