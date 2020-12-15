import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:path_provider/path_provider.dart';


class FileManager{


  ///Creates a directory inside the students/ folder with the specified [name]
  static createDir(String name) async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();

    new Directory(appDocDirectory.path + '/students/' + name).create(recursive: true)
    // The created directory is returned as a Future.
        .then((Directory directory) {
      print(directory.path);
    });
  }

  ///Deletes the specified [user] within the students/ folder
  static deleteDir(String user) async{
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + "/students/$user";
    final dir = Directory(path);
    dir.deleteSync(recursive: true);
  }

  ///Displays recursively all contents within the students/ folder
  static listDirContents() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + "/students";
    var dir = Directory(path);

    try {
      var dirList = dir.list(recursive: true, followLinks: false);
      await for (FileSystemEntity f in dirList) {
        if (f is File) {
          print('Found file ${f.path}');
        } else if (f is Directory) {
          print('Found dir ${f.path}');
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }




  static Future<File> localFile(String user, String form) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + "/$user";
    print("file path: $path");
    return File('$path/$form');
  }

  static createFile(String user, String form) async{

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + "/$user";

    // Create a file, read the entire contents and print line by line
    final file = File('$path/$form');
    file.create();
  }

}