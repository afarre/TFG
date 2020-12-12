import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:qr_games/model/form.dart';

class EndpointData {
  EndpointData(this.name, this.id, this.token, this.isIncoming);

  final String name;
  final String id;
  final String token;
  bool isIncoming;

  @override
  String toString() {
    return 'name: ' + name +
        '\nid: ' + id +
        '\ntoken: ' + token +
        '\nisIncoming: ' + isIncoming.toString();
  }
}

class ConnectionData {
  ConnectionData(this.id, this.status);

  final String id;
  final Status status;

  @override
  String toString() {
    return 'id: ' + id +
        '\nstatus: ' + status.toString();
  }
}

class EndpointList extends StatefulWidget{
  List<EndpointData> _endpointList;
  EndpointList(List<EndpointData> endpointList){
    _endpointList = endpointList;
  }

  createState() => EndpointListPublic(_endpointList);
}

class EndpointListPublic extends State<EndpointList> with WidgetsBindingObserver{
  final Strategy strategy = Strategy.P2P_STAR;
  String cId = "0"; //currently connected device ID
  File tempFile; //reference to the file currently being transferred
  Map<int, String> map = Map();
  List<EndpointData> endpointList = <EndpointData>[];
  String name = "teacher";

  EndpointListPublic(this.endpointList);

  @override
  void initState(){
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    advertiseDevice();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //primer pop up
  void advertiseDevice() async{
    try {
      bool a = await Nearby().startAdvertising(
        name,
        strategy,
        onConnectionInitiated: onConnectionInit,
        onConnectionResult: (id, status) {
          showSnackbar(status);
          showSnackbar(id);
          return new ConnectionData(id, status);
        },
        onDisconnected: (id) {
          showSnackbar("Disconnected: " + id);
          return new ConnectionData(id, null);
        },
      );
      showSnackbar("ADVERTISING: " + a.toString());
    } catch (exception) {
      showSnackbar(exception);
    }
    return null;
  }

  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }

  /// Called upon Connection request (on both devices)
  /// Both need to accept connection to start sending/receiving
  void onConnectionInit(String id, ConnectionInfo info) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Center(
          child: Column(
            //segon pop up
            children: <Widget>[
              Text("id: " + id),
              Text("Token: " + info.authenticationToken),
              Text("Name: " + info.endpointName),
              Text("Incoming: " + info.isIncomingConnection.toString()),
              RaisedButton(
                child: Text("Accept Connection"),
                onPressed: () {
                  Navigator.pop(context);
                  cId = id;
                  print("cId: $cId\nid: $id");
                  setState(() {
                    endpointList.add(new EndpointData(info.endpointName, id, info.authenticationToken, info.isIncomingConnection));
                  });
                  Nearby().acceptConnection(
                    id,
                    onPayLoadRecieved: (endid, payload) async {
                      print("received payload");
                      if (payload.type == PayloadType.BYTES) {
                        String str = String.fromCharCodes(payload.bytes);
                        print(endid + ": " + str);
                        Map<String, dynamic> decodedForm = jsonDecode(str);
                        FormModel form = FormModel.fromJson(decodedForm);
                        showSnackbar("File received from $endid. Storing in ${form.title} folder.");
                        //TODO: Guardar el formulari a la carpeta del alumne


                      } else if (payload.type == PayloadType.FILE) {
                        showSnackbar(endid + ": File transfer started");
                        tempFile = File(payload.filePath);
                      }
                    },
                    onPayloadTransferUpdate: (endid, payloadTransferUpdate) {
                      if (payloadTransferUpdate.status == PayloadStatus.IN_PROGRRESS) {
                        print(payloadTransferUpdate.bytesTransferred);
                      } else if (payloadTransferUpdate.status == PayloadStatus.FAILURE) {
                        print("failed");
                        showSnackbar(endid + ": FAILED to transfer file");
                      } else if (payloadTransferUpdate.status == PayloadStatus.SUCCESS) {
                        showSnackbar("success, total bytes = ${payloadTransferUpdate.totalBytes}");

                        if (map.containsKey(payloadTransferUpdate.id)) {
                          //rename the file now
                          String name = map[payloadTransferUpdate.id];
                          tempFile.rename(tempFile.parent.path + "/" + name);
                        } else {
                          //bytes not received till yet
                          map[payloadTransferUpdate.id] = "";
                        }
                      }
                    },
                  );
                },
              ),
              RaisedButton(
                child: Text("Reject Connection"),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await Nearby().rejectConnection(id);
                  } catch (e) {
                    showSnackbar(e);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("printing list contents in view build:");
    print(endpointList.toString());
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, endpointList);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
            Navigator.pop(context, endpointList);
          },),
          title: Text('Connected devices'),
        ),
        body: ListView.builder(
          itemCount: endpointList.length,
          itemBuilder: (context, index){
            return fillSingleCellCool(endpointList[index]);
/*
            final endpoint = endpointList[index];
            return ListTile(
              title: Text(
                "Name: " + endpoint.name,
                style: Theme.of(context).textTheme.headline5,
              ),
              subtitle: Text("Id: " + endpoint.id + "\nAuthentication Token:" + endpoint.token),
              onTap: () => onTapped(index, context),
            );
 */
          },
        )
      ),
    );
  }

  onTapped(int index, BuildContext context) {
    showDialog(context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: new Text("Escolleix que vols fer"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Marca/Desmarca tasca"),
              onPressed: () {
                //taskComplete.fillRange(index, index + 1, !taskComplete.elementAt(index));
                setState(() {

                });
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Esborra tasca"),
              onPressed: () {
                //taskList.removeAt(index);
                //taskComplete.removeAt(index);
                //numElements--;
                setState(() {

                });
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Cancel·la"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  fillSingleCellCool(EndpointData event) {
    return Container(
        height: 250,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          fit: StackFit.loose,
          children: <Widget>[
            Positioned (
              top: 0,
              right: 0,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                      radius: 1,
                      center: Alignment(1, -1),
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent
                      ]
                  ), //linear gradient
                ),
              ),
            ),

            Positioned(
              bottom: 0,

              child: GestureDetector(
                  child:Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black
                            ]
                        ), //linear gradient
                      ), //decoration
                      child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 20.0, 0, 10.0),
                                    child: Text(
                                        insertText(event.name),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 20
                                        ) //text style
                                    ) //text
                                ), //text padding

                                Row(
                                  children: <Widget>[
                                    Text(
                                        insertText(event.id),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white
                                        ) //text style
                                    ),
                                    Text(
                                        insertText(event.token),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white
                                        ) //text style
                                    )
                                  ],
                                )
                                //text
                              ] //column children
                          ) //column
                      ) //column padding
                  )
              ), //container
            ), //info positioned
          ], //stack children
        ) //big stack
    ); //container
  }

  insertText(String text) {
    if (text != null) {
      return text;
    } else {
      return "No specific time";
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
    if(state == AppLifecycleState.detached || state == AppLifecycleState.inactive || state == AppLifecycleState.paused){
      print("stopped advertising");
      Nearby().stopAdvertising();
    }else if (state == AppLifecycleState.resumed){
      advertiseDevice();
    }
  }
}