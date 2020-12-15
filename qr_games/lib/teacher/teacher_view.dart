
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:qr_games/common/file_manager.dart';
import 'package:qr_games/model/endpoint_data.dart';
import 'package:qr_games/teacher/create_forms.dart';
import 'package:qr_games/teacher/endpoint_list.dart';
import 'package:qr_games/teacher/saved_forms.dart';

class TeacherView extends StatefulWidget {
  _MyTeacherViewState createState() => _MyTeacherViewState();
}

class _MyTeacherViewState extends State<TeacherView>{
  List<EndpointData> endpointList = <EndpointData>[];
  CreateForms createForms = CreateForms();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){
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
            print("Create form view selected");
            Navigator.push(context, MaterialPageRoute(builder: (context) => createForms));
          },
        ),
        RaisedButton(
          child: const Text('My forms', style: TextStyle(fontSize: 20)),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SavedForms(endpointList)));
          },
        ),
        RaisedButton(
          child: const Text('Advertise device', style: TextStyle(fontSize: 20)),
          onPressed: () async {
            print("Advertise/view selected.");
            print("about to ask storage permission");
            Nearby().askExternalStoragePermission();
            var navigationResult = await Navigator.push(context, MaterialPageRoute(builder: (context) => EndpointList(endpointList)));
            endpointList = navigationResult;
            Nearby().stopAdvertising();
            print("stopped advertising");
          }
        ),
        RaisedButton(
          child: const Text('Stop all endpoints', style: TextStyle(fontSize: 20)),
          onPressed: () {
            Nearby().stopAllEndpoints();
            endpointList = <EndpointData>[];
          },
        ),
        RaisedButton(
          child: const Text('Student forms', style: TextStyle(fontSize: 20)),
          onPressed: () {
            //Navigator.push(context, MaterialPageRoute(builder: (context) => test()));
          },
        ),

        RaisedButton(
          child: const Text('delet this'),
          onPressed: () {
            //FileManager.createFile("39281a04d2b8c8ba", "randForm");
            //MySharedPreferences.deleteData('39281a04d2b8c8ba');
            FileManager.listDirContents();
            //FileManager.deleteDir("39281a04d2b8c8ba");

            //FileManager.deleteDir("/data/user/0/com.afarre.qr_games/app_flutter/39281a04d2b8c8ba");
//            FileManager.asd("");

            //Navigator.push(context, MaterialPageRoute(builder: (context) => test()));
          },
        ),

      ],
    );
  }
}