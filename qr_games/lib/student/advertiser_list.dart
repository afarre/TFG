import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:qr_games/common/shared_preferences.dart';
import 'package:qr_games/model/advertiser_data.dart';
import 'package:qr_games/model/form.dart';
import 'package:qr_games/settings/settings_view.dart';

import 'build_forms.dart';


class AdvertiserList extends StatefulWidget{
  final List<AdvertiserData> advertiserList;
  AdvertiserList(this.advertiserList);

  @override
  State<StatefulWidget> createState() => _AdvertiserList();
}

class _AdvertiserList extends State<AdvertiserList> with WidgetsBindingObserver{
  static const Strategy _strategy = Strategy.P2P_STAR;
  Map<int, String> _map = Map();
  File _tempFile; //reference to the file currently being transferred
  FormModel _form;
  String _teacherId;
  String _name;

  @override
  void initState(){
    _discoverDevices();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //primer pop up
  void _discoverDevices() async{
    String name = await MySharedPreferences.getUserName();
    _name = name;
    try {
      await Nearby().startDiscovery(name,
        _strategy,
        onEndpointFound: (endpointId, endpointName, endpointServiceId) {
          AdvertiserData advertiserData = AdvertiserData(endpointName, endpointId, endpointServiceId, false);
          //WidgetsBinding.instance.addPostFrameCallback((_){
            setState(() {
              bool inList = false;
              for(AdvertiserData advertiserData in widget.advertiserList){
                if(advertiserData.id == endpointId){
                  inList = true;
                  break;
                }
              }
              if(!inList){
                widget.advertiserList.add(advertiserData);
              }
            });
          //});
        },
        onEndpointLost: (endpointId) {
          //showSnackbar("Lost Endpoint:" + endpointId);
          print("lost endpoint");
        },
      );
      _showSnackbar("Device currently discovering!");
    } catch (exception) {
      //status: already discovering
      print("startDiscovery catch: ${exception.toString()}");
    }
  }

  void _showSnackbar(dynamic msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg.toString()),
    ));
  }

  /// Called upon Connection request (on both devices)
  /// Both need to accept connection to start sending/receiving
  void _onConnectionInit(String id, ConnectionInfo info) {
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
                  //set state
                  Nearby().acceptConnection(
                    id,
                    onPayLoadRecieved: (endid, payload) async {
                    if (payload.type == PayloadType.BYTES) {
                      print("got payload BYTES");
                      String str = String.fromCharCodes(payload.bytes);
                      print("str: $str");

                      Map<String, dynamic> decodedForm = jsonDecode(str);
                      print("decoded form: $decodedForm");
                      _form = FormModel.fromJson(decodedForm);
                      print("form title: " + _form.title);

                      _promptForForm(_form);
                    } else if (payload.type == PayloadType.FILE) {
                      print("got payload FILES");
                      _showSnackbar(endid + ": File transfer started");
                      _tempFile = File(payload.filePath);
                    }
                  },
                    onPayloadTransferUpdate: (endid, payloadTransferUpdate) {
                      if (payloadTransferUpdate.status == PayloadStatus.IN_PROGRRESS) {
                        print(payloadTransferUpdate.bytesTransferred);
                      } else if (payloadTransferUpdate.status == PayloadStatus.FAILURE) {
                        print("failed");
                        _showSnackbar(endid + ": FAILED to transfer file");
                      } else if (payloadTransferUpdate.status == PayloadStatus.SUCCESS) {

                        if (_map.containsKey(payloadTransferUpdate.id)) {
                          //rename the file now
                          String name = _map[payloadTransferUpdate.id];
                          _tempFile.rename(_tempFile.parent.path + "/" + name);
                        } else {
                          //bytes not received till yet
                          _map[payloadTransferUpdate.id] = "";
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
                    print("rejectConnection catch: ${e.toString()}");
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
    print("printing list contents in view build: ${widget.advertiserList.toString()}");
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, widget.advertiserList);
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
              Navigator.pop(context, widget.advertiserList);
            },),
            title: Text('Discovering devices'),
          ),
          body: ListView.builder(
            itemCount: widget.advertiserList.length,
            itemBuilder: (context, index){
              return _fillSingleCellCool(widget.advertiserList[index]);
            },
          )
      ),
    );
  }

  _connectToAdvertiser(AdvertiserData data) {
    Nearby().stopDiscovery();
    _teacherId = data.id;
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
              Text("Name: " + data.name),
              Text("Id: " + data.id),
              Text("ServiceId: " + data.serviceId),
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
                    _name,
                    data.id,
                    onConnectionInitiated: (id, info) {
                      _onConnectionInit(id, info);
                    },
                    onConnectionResult: (id, status) {
                      if(status == Status.CONNECTED){
                        SettingsView.getDeviceDetails().then((value){
                          Nearby().sendBytesPayload(id, Uint8List.fromList(("UUID" + value[2]).codeUnits));
                        });
                        setState(() {
                          widget.advertiserList[widget.advertiserList.indexOf(data)].connected = true;
                        });
                      }
                    },
                    onDisconnected: (id) {
                      _showSnackbar("Disconnected $id");
                      print("disconnected");
                      setState(() {
                        widget.advertiserList[widget.advertiserList.indexOf(data)].connected = false;
                      });
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _fillSingleCellCool(AdvertiserData data) {
    Color colors;
    if(data.connected){
      colors = Colors.green;
    }else{
      colors = Colors.black;
    }
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
                      colors,
                      Colors.transparent
                    ]
                ), //linear gradient
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: GestureDetector(
              onTap: () => _connectToAdvertiser(data),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      colors.withOpacity(0.6)
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
                            _insertText(data.name),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20
                            ) //text style
                        ) //text
                      ), //text padding
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _insertText("Id: ${data.id}"),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                            ) //text style
                          ),
                          Text(
                            _insertText("Service id: ${data.serviceId}"),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                            ) //text style
                          )
                        ],
                      )
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

  _insertText(String text) {
    if (text != null) {
      return text;
    } else {
      return "No specific time";
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.detached || state == AppLifecycleState.inactive || state == AppLifecycleState.paused){
      print("stopped discovery");
      widget.advertiserList.clear();
      Nearby().stopDiscovery();
    }else if (state == AppLifecycleState.resumed){
      print("discovering because state resumed");
      _discoverDevices();
    }
  }

  void _promptForForm(FormModel form) {
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
                        Nearby().stopDiscovery();
                        Navigator.pop(context, widget.advertiserList);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => BuildForm(form, _teacherId)));
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