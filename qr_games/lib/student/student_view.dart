import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:qr_games/model/advertiser_data.dart';
import 'package:qr_games/student/advertiser_list.dart';

class StudentView extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _StudentView();
}

class _StudentView extends State<StudentView>{
  String _currentId = "0"; //currently connected device ID

  @override
  Widget build(BuildContext context) {
    List<AdvertiserData> advertisingList = <AdvertiserData>[];
    return GridView.count(
      crossAxisCount: 2 ,
      childAspectRatio: 3/2,
      padding: const EdgeInsets.all(15.0),
      mainAxisSpacing: 15.0,
      crossAxisSpacing: 30.0,
      children: <Widget>[
        RaisedButton(
          child: const Text('See received forms', style: TextStyle(fontSize: 20)),
          onPressed: () {

          },
        ),
        RaisedButton(
          child: const Text('Disconnect from teacher', style: TextStyle(fontSize: 20)),
          onPressed: () {
            Nearby().disconnectFromEndpoint(_currentId);
          },
        ),
        RaisedButton(
            child: const Text('Discover devices', style: TextStyle(fontSize: 20)),
          onPressed: () async {
            await Nearby().askLocationPermission();
            var navigationResult =  await Navigator.push(context, MaterialPageRoute(builder: (context) => AdvertiserList(advertisingList)));
            advertisingList = navigationResult;
            Nearby().stopDiscovery();
            print("stopped discovering");
          },
        ),
        RaisedButton(
          child: const Text('Disconnect', style: TextStyle(fontSize: 20)),
          onPressed: () {
            Nearby().stopAllEndpoints();
            advertisingList.clear();
          },
        ),
      ],
    );
  }
}