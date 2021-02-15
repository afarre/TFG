import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:qr_games/common/shared_preferences.dart';
import 'package:wifi_iot/wifi_iot.dart';


class SettingsView extends StatefulWidget{
  _SettingsView createState() => _SettingsView();


  static Future<List<String>> getDeviceDetails() async {
    String deviceName;
    String deviceVersion;
    String identifier;
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceName = build.model;
        deviceVersion = build.version.toString();
        identifier = build.androidId;  //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceName = data.name;
        deviceVersion = data.systemVersion;
        identifier = data.identifierForVendor;  //UUID for iOS
      }
    } on PlatformException {
      print('Failed to get platform version');
    }

//if (!mounted) return;
    return [deviceName, deviceVersion, identifier];
  }
}

class _SettingsView extends State<SettingsView> with WidgetsBindingObserver{
  bool _wiFiIsEnabled = false;
  bool _locationIsEnabled = false;
  bool _displayFuture = true;
  final _myController = TextEditingController();


  Future<String> getName() async{
    String name = await MySharedPreferences.getUserName();
    return name;
  }

  @override
  void initState() {
    WiFiForIoTPlugin.isEnabled().then((val) {
      if (val != null) {
        _wiFiIsEnabled = val;
      }
    });
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if(this.mounted){
      nameSubmitted(_myController.text);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.detached || state == AppLifecycleState.inactive || state == AppLifecycleState.paused){
      nameSubmitted(_myController.text);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name"),
                FutureBuilder(
                  future: getName(),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                    if(snapshot.hasData && _displayFuture){
                      //print("building future with data");
                      _myController.text = snapshot.data;
                      return TextField(
                        controller: _myController,
                        decoration: new InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                        onTap: (){
                          _displayFuture = false;
                        },
                        onSubmitted: nameSubmitted,
                      );
                    }else{
                      return TextField(
                        controller: _myController,
                        decoration: new InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          //hintText: 'Your name',
                        ),
                        onTap: (){
                          _displayFuture = false;
                        },
                        onSubmitted: nameSubmitted,
                      );
                    }
                  }
                ),
              ],
            ),
          ),
          new Divider(height: 15.0,color: Colors.blueGrey),
          _getWiFi(),
          _getLocation(),
          //_getBluetooth(),
          //TODO: Implement bluetooth switch
        ],
      ),
    );
  }

  _getWiFi() {
    WiFiForIoTPlugin.isEnabled().then((val) => setState(() {
      _wiFiIsEnabled = val;
    }));

    return ListTile(
      title: Row(
        children: [
          Icon(Icons.wifi),
          Text("\tWifi"),
          Spacer(),
          Switch(
            value: _wiFiIsEnabled,
            onChanged: (value){
              setState(() {
                _wiFiIsEnabled = !_wiFiIsEnabled;
                if(_wiFiIsEnabled){
                  WiFiForIoTPlugin.setEnabled(true);
                }else{
                  WiFiForIoTPlugin.setEnabled(false);
                }
              });
            }
          )
        ],
      ),
    );
  }

  _getLocation() {
    /*Nearby().checkLocationEnabled().then((val) => setState(() {
      _locationIsEnabled = val;
    }));

     */

    return ListTile(
      title: Row(
        children: [
          Icon(Icons.location_on),
          Text("\tLocation"),
          Spacer(),
          Switch(
            value: _locationIsEnabled,
            onChanged: (value){
              setState(() {
                _locationIsEnabled = !_locationIsEnabled;
                if(_locationIsEnabled){
                  Nearby().enableLocationServices();
                }else{
                  //TODO: Disable location services
                }
              });
            }
          )
        ],
      ),
    );
  }

  void nameSubmitted(String value) {
    MySharedPreferences.setUserName(_myController.text);
    _displayFuture = true;
  }
}

