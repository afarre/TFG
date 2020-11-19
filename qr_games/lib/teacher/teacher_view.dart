import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:qr_games/teacher/endpoint_list.dart';

class TeacherView extends StatefulWidget {
  _MyTeacherViewState createState() => _MyTeacherViewState();
}

class _MyTeacherViewState extends State<TeacherView>{

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
          child: const Text('Advertise device', style: TextStyle(fontSize: 20)),
          onPressed: () async {
            print("Advertise/view selected.");
            var navigationResult = await Navigator.push(context, MaterialPageRoute(builder: (context) => EndpointList()));
            if(navigationResult == true){
              Nearby().stopAdvertising();
              print("stopped advertising");
            }
          },
        ),
      ],
    );
  }
}