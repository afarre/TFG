import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:qr_games/common/shared_preferences.dart';
import 'package:qr_games/model/form.dart';
import 'package:qr_games/settings/settings_view.dart';
import 'package:qr_games/student/build_forms.dart';

class StudentView extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _MyStudentViewState();
}

class _MyStudentViewState extends State<StudentView>{
  final Strategy strategy = Strategy.P2P_STAR;
  String cId = "0"; //currently connected device ID
  Map<int, String> map = Map();
  File tempFile; //reference to the file currently being transferred
  FormModel form;
  String teacherId;

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
          child: const Text('Build forms', style: TextStyle(fontSize: 20)),
          onPressed: () {

          },
        ),
        RaisedButton(
          child: const Text('Share forms', style: TextStyle(fontSize: 20)),
          onPressed: () {
            Nearby().sendBytesPayload(cId, "poia".codeUnits);

          },
        ),
        RaisedButton(
            child: const Text('Discover devices', style: TextStyle(fontSize: 20)),
          onPressed: () async {
            try {
              await Nearby().askLocationPermission();
              /*
              if (await Nearby().askLocationPermission()) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Location Permission granted :)")));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                    Text("Location permissions not granted :(")));
              }
              */
              String name = await MySharedPreferences.getUserName();
              print("name: $name");
              bool a = await Nearby().startDiscovery(
                name,
                strategy,
                onEndpointFound: (endpointId, endpointName, endpointServiceId) {
                  Nearby().stopDiscovery();
                  teacherId = endpointId;
                  // show sheet automatically to request connection
                  showModalBottomSheet(
                    context: context,
                    builder: (builder) {
                      return Center(
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.drag_handle, size: 35),
                            SizedBox(
                              height: 5,
                            ),
                            Text("Device found", style: TextStyle(fontSize: 20.0)),
                            const Divider(
                              color: Colors.black,
                              height: 20,
                              thickness: 1,
                              indent: 15,
                              endIndent: 15,
                            ),
                            Text("Name: " + endpointName),
                            Text("Id: " + endpointId),
                            Text("ServiceId: " + endpointServiceId),
                            const Divider(
                              color: Colors.black,
                              height: 20,
                              thickness: 1,
                              indent: 15,
                              endIndent: 15,
                            ),
                            RaisedButton(
                              child: Text("Request Connection", style: TextStyle(fontSize: 20.0)),
                              onPressed: () {
                                Navigator.pop(context);
                                Nearby().requestConnection(
                                  name,
                                  endpointId,
                                  onConnectionInitiated: (id, info) {
                                    onConnectionInit(id, info);
                                  },
                                  onConnectionResult: (id, status) {
                                    SettingsView.getDeviceDetails().then((value){
                                      print("sending UUID to teacher: ${value[2]}");
                                      Nearby().sendBytesPayload(id, Uint8List.fromList(("UUID" + value[2]).codeUnits));
                                    });
                                    showSnackbar("status: $status");
                                  },
                                  onDisconnected: (id) {
                                    showSnackbar("disconnected $id");
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                onEndpointLost: (endpointId) {
                  showSnackbar("Lost Endpoint:" + endpointId);
                },
              );
              showSnackbar("DISCOVERING: " + a.toString());
            } catch (e) {
              showSnackbar("catch $e");
            }
          },
        ),
      ],
    );
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
                  //set state
                  Nearby().acceptConnection(id, onPayLoadRecieved: (endid, payload) async {
                      if (payload.type == PayloadType.BYTES) {
                        print("got payload BYTES");
                        String str = String.fromCharCodes(payload.bytes);
                        print("str: $str");

                        Map<String, dynamic> decodedForm = jsonDecode(str);
                        print("decoded form: $decodedForm");
                        form = FormModel.fromJson(decodedForm);
                        print("form title: " + form.title);

                        promptForForm(form);

                      } else if (payload.type == PayloadType.FILE) {
                        print("got payload FILES");
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
                    showSnackbar("another catch $e");
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void promptForForm(FormModel form) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Center(
          child: Column(
            children: <Widget>[
              Text("Got a form titled: " + form.title + ". Do you want to open it?"),
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
                    child: Text('Yes', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BuildForm(form, teacherId)));
                    },
                  ), flex: 3)
                ],
              )
            ],
          ),
        );
      }
    );
  }
}