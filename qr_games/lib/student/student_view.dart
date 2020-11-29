
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';

class StudentView extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _MyStudentViewState();
}

class _MyStudentViewState extends State<StudentView>{
  final Strategy strategy = Strategy.P2P_STAR;
  String cId = "0"; //currently connected device ID
  Map<int, String> map = Map();
  File tempFile; //reference to the file currently being transferred

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

          },
        ),
        RaisedButton(
          child: const Text('Share forms', style: TextStyle(fontSize: 20)),
          onPressed: () {
            String a = Random().nextInt(100).toString();

          },
        ),
        RaisedButton(
            child: const Text('Discover devices', style: TextStyle(fontSize: 20)),
          onPressed: () async {
            try {
              bool a = await Nearby().startDiscovery(
                "student",
                strategy,
                onEndpointFound: (id, name, serviceId) {
                  // show sheet automatically to request connection
                  showModalBottomSheet(
                    context: context,
                    builder: (builder) {
                      return Center(
                        child: Column(
                          children: <Widget>[
                            Text("id: " + id),
                            Text("Name: " + name),
                            Text("ServiceId: " + serviceId),
                            RaisedButton(
                              child: Text("Request Connection"),
                              onPressed: () {
                                Navigator.pop(context);
                                Nearby().requestConnection(
                                  "student",
                                  id,
                                  onConnectionInitiated: (id, info) {
                                    onConnectionInit(id, info);
                                  },
                                  onConnectionResult: (id, status) {
                                    showSnackbar(status);
                                  },
                                  onDisconnected: (id) {
                                    showSnackbar(id);
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
                onEndpointLost: (id) {
                  showSnackbar("Lost Endpoint:" + id);
                },
              );
              showSnackbar("DISCOVERING: " + a.toString());
            } catch (e) {
              showSnackbar(e);
            }
          },
        ),
      ],
    );
  }

  void showSnackbar(dynamic a) {
    Scaffold.of(context).showSnackBar(SnackBar(
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
                        String str = String.fromCharCodes(payload.bytes);
                        showSnackbar(endid + ": " + str);
                        print("got this information: " + str);

                        if (str.contains(':')) {
                          // used for file payload as file payload is mapped as
                          // payloadId:filename
                          int payloadId = int.parse(str.split(':')[0]);
                          String fileName = (str.split(':')[1]);

                          if (map.containsKey(payloadId)) {
                            if (await tempFile.exists()) {
                              tempFile.rename(
                                  tempFile.parent.path + "/" + fileName);
                            } else {
                              showSnackbar("File doesnt exist");
                            }
                          } else {
                            //add to map if not already
                            map[payloadId] = fileName;
                          }
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
}