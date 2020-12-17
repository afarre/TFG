import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;


class FileManager{

  static const DISPLAY_ALL = 0;
  static const DISPLAY_FILES = 1;
  static const DISPLAY_DIRECTORIES = 2;

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

  ///Displays recursively basenames within the students/ folder.
  ///[display] indicates wether results should be dir, folder or both
  static Future<List> listDirContents(int display) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + "/students";
    var dir = Directory(path);
    List<String> results = [];

    try {
      var dirList = dir.list(recursive: true, followLinks: false);
      await for (FileSystemEntity f in dirList) {
        if (f is File && display == DISPLAY_FILES) {
          print('Found file ${p.basename(f.path)}');
          results.add(p.basename(f.path));
        } else if (f is Directory && display == DISPLAY_DIRECTORIES) {
          print('Found dir ${p.basename(f.path)}');
          results.add(p.basename(f.path));
        }else if (display == DISPLAY_ALL){
          print('Found dir/file ${p.basename(f.path)}');
          results.add(p.basename(f.path));
        }
      }
      return results;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<File> createFile(String user, String formName) async{
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + "/students/$user/$formName.json";

    // Create a file, read the entire contents and print line by line
    File file = File(path);
    file.create();
    return file;
  }

  static Future<String> getFileContent(String user, String formName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + "/students/$user/$formName";
    print("path: $path");

    String value = await File(path).readAsString();
    print("contents: $value");
    return value;

  }

  ///Returns a list of basenames of all files located inside the specified [student] folder
  static listStudentForms(String student) async {
    print("listing for $student");
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + "/students/$student";
    var dir = Directory(path);
    List<String> results = [];

    try {
      var dirList = dir.list(recursive: true, followLinks: false);
      await for (FileSystemEntity f in dirList) {
        if (f is File) {
          print('Found file ${p.basename(f.path)}');
          results.add(p.basename(f.path));
        }
      }
      return results;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static void renameDir(String oldName, String newName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + "/students/$oldName";
    Directory dir = Directory(path);
    print("got dir no problem: ·${dir.path}");
    dir.rename(directory.path + "/students/$newName");
  }
}