import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_games/model/endpoint_data.dart';

class MySharedPreferences {

  ///Returns all keys contained in Shared Preferences
  static Future<Set<String>> getKeys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final value = prefs.getKeys();
    return value;
  }

  ///Gets the data associated to the specified [key]
  static Future getData(String key) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key) ?? 0;
    return value;
  }

  ///Returns true if the specified [key] exists
  static Future contains(String key) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  ///Deletes the data associated to the specified [key]
  static deleteData(String key) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
    print("deleted $key");
  }

  ///Sets the specified [data] with it's corresponding [key]
  static setData(String data, String key) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, data);
    print('saved data $data');
  }

  ///Saved the specified [name] under the 'userName' key
  static setUserName(String name) async{
    final prefs = await SharedPreferences.getInstance();
    final key = 'userName';
    final value = name;
    prefs.setString(key, value);
    print('saved $value');
  }

  static Future<EndpointData> getEndpoint(String id) async {
    print("id: $id");
    final prefs = await SharedPreferences.getInstance();
    for (String key in prefs.getKeys()){
      if (!key.contains("#") && key != "userName"){
        var value = await getData(key);
        print("for key: $key, data :$value");
        Map<String, dynamic> endpointJson = jsonDecode(value);
        EndpointData endpoint = EndpointData.fromJson(endpointJson);
        if (endpoint.id == id){
          print("${endpoint.id} equals $id, therefore returning ${endpoint.uuid}");
          return endpoint;
        }
      }else{
        continue;
      }
    }
    return null;
  }

  static Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final value = prefs.getString("userName") ?? "unnamed";
    //print("getUserName: $value");
    return value;
  }
}