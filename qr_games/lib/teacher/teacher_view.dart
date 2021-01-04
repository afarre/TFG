
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:qr_games/common/file_manager.dart';
import 'package:qr_games/model/endpoint_data.dart';
import 'package:qr_games/teacher/create_form.dart';
import 'package:qr_games/teacher/endpoint_list.dart';
import 'package:qr_games/teacher/my_forms.dart';
import 'package:qr_games/teacher/student_management/student_answer_list.dart';
import 'package:qr_games/model/advertiser_data.dart';

class TeacherView extends StatelessWidget {

  @override
  Widget build(BuildContext context){
    List<EndpointData> endpointList = <EndpointData>[];

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
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateForms()));
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
            endpointList.clear();
          },
        ),
        RaisedButton(
          child: const Text('Student forms', style: TextStyle(fontSize: 20)),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => StudentAnswerList()));
          },
        ),

        RaisedButton(
          child: const Text('testing'),
          onPressed: () async {
            //FileManager.createFile("39281a04d2b8c8ba", "randForm");
            /*
            MySharedPreferences.deleteData('4c434612edcff4bc');
            MySharedPreferences.deleteData('39281a04d2b8c8ba');
            FileManager.deleteDir("student");
            FileManager.listDirContents(FileManager.DISPLAY_ALL);

             */


            await FileManager.listDirContents(FileManager.DISPLAY_ALL);
            //Navigator.push(context, MaterialPageRoute(builder: (context) => test()));

          },
        ),
      ],
    );
  }
}