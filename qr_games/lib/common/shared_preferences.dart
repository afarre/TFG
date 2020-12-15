import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_games/model/endpoint_data.dart';

class MySharedPreferences {

  ///Returns all keys contained in Shared Preferences
  static Future<Set<String>> getKeys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final value = prefs.getKeys();
    print("got ${value.length} results");
    return value;
  }

  ///Gets the data associated to the specified [key]
  static Future getData(String key) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key) ?? 0;
    print('read: $value');
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
    print('saved $data');
  }

  ///Saved the specified [name] under the 'userName' key
  static saveUserName(String name) async{
    final prefs = await SharedPreferences.getInstance();
    final key = 'userName';
    final value = name;
    prefs.setString(key, value);
    print('saved $value');
  }

  static Future<String> getUuid(String id) async {
    final prefs = await SharedPreferences.getInstance();
    for (String key in prefs.getKeys()){
      print("looking at $key");
      if (!key.contains("#")){
        print("in if");
        return getData(key).then((value){
          print("got this value: $value");
          Map<String, dynamic> endpointJson = jsonDecode(value);
          EndpointData endpoint = EndpointData.fromJson(endpointJson);
          print("endpoint.id: ${endpoint.id}");
          print("id: $id");
          if (endpoint.id == id){
            print("first return i al carrer");
            return endpoint.uuid;
          }
          return null;
        });
      }else{
        continue;
      }
    }
  }
}