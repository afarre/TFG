import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:wifi_iot/wifi_iot.dart';


class SettingsView extends StatefulWidget{
  _SettingsView createState() => _SettingsView();
}

class _SettingsView extends State<SettingsView>{
  String _name = "teacher";
  bool _wiFiIsEnabled = false;
  bool _locationIsEnabled = false;

  @override
  initState() {
    WiFiForIoTPlugin.isEnabled().then((val) {
      if (val != null) {
        _wiFiIsEnabled = val;
      }
    });
    super.initState();
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
                TextField(
                  decoration: new InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'Your name',
                  ),
                ),
              ],
            ),
          ),
          new Divider(height: 15.0,color: Colors.blueGrey),
          getWiFi(),
          getLocation(),
        ],
      ),
    );
  }

  getWiFi() {
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

  getLocation() {
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
}

