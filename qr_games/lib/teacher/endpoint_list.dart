import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:qr_games/model/connections_data.dart';
import 'package:qr_games/model/endpoint_data.dart';
import 'package:qr_games/model/form.dart';
import 'package:qr_games/common/shared_preferences.dart';
import 'package:qr_games/common/file_manager.dart';


class EndpointList extends StatefulWidget{
  List<EndpointData> _endpointList;
  EndpointList(this._endpointList);

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
          //TODO: controlar desconections (netejar de la llista de la vista)
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
                  Nearby().acceptConnection(
                    id,
                    onPayLoadRecieved: (endid, payload) async {
                      print("received payload");
                      String str = String.fromCharCodes(payload.bytes);
                      if (payload.type == PayloadType.BYTES) {
                        print(endid + ": " + str);

                        if(str.startsWith("UUID")){
                          handleInitialConnection(str, info, id);

                          print(endpointList.toString());
                        }else{
                          Map<String, dynamic> decodedForm = jsonDecode(str);
                          FormModel form = FormModel.fromJson(decodedForm);
                          print("student answered with this form: $decodedForm");
                          MySharedPreferences.getUuid(id).then((uuid) {
                            print("ended up with this uuid: $uuid");
                            FileManager.listDirContents();
                            FileManager.createFile(uuid, form.title).then((file) => {
                              file.writeAsString(str)
                            });
                          });

                          //showSnackbar("File received from $endid. Storing in ${form.title} folder.");
                          //TODO: Guardar el formulari a la carpeta ja creada del alumne
                        }

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

  void handleInitialConnection(String str, ConnectionInfo info, String id) {
    print("in handle with str: $str and id: $id");
    String uuid = str.replaceFirst("UUID", "");
    MySharedPreferences.contains(uuid).then((isRegistered){
      if (isRegistered){
        print("old device");
        MySharedPreferences.getData(uuid).then((oldEndpointData){
          Map<String, dynamic> oldDecodedEndpoint = jsonDecode(oldEndpointData);
          print("decoded form: $oldDecodedEndpoint");
          EndpointData endpointData = EndpointData.fromJson(oldDecodedEndpoint);
          endpointData.name = info.endpointName;
          endpointData.isIncoming = info.isIncomingConnection;
          endpointData.token = info.authenticationToken;
          endpointData.id = id;
          MySharedPreferences.deleteData(endpointData.uuid);
          String endpointJson = jsonEncode(endpointData);
          MySharedPreferences.setData(endpointJson, uuid);
          print("updated endpoint: $endpointJson");

          print(endpointList.length);
          if(endpointList.isEmpty){
            setState(() {
              endpointList.add(endpointData);
            });
          }else{
            endpointList.forEach((element) {
              if(element.uuid == uuid){
                print("was already in view (duplicate)");
                setState(() {
                  element.name = info.endpointName;
                  element.isIncoming = info.isIncomingConnection;
                  element.token = info.authenticationToken;
                  element.id = id;
                });
              }else{
                print("was not displayed in view");
                setState(() {
                  endpointList.add(endpointData);
                  print(endpointList.last.toString());
                });
              }
            });
          }
        });
      }else{
        print("new device");
        EndpointData endpointData = new EndpointData(info.endpointName, id, info.authenticationToken, info.isIncomingConnection, uuid);
        String endpointJson = jsonEncode(endpointData);
        MySharedPreferences.setData(endpointJson, uuid);
        setState(() {
          endpointList.add(endpointData);
          print(endpointList.last.toString());
        });
        FileManager.createDir(uuid);
      }
    });
  }


}