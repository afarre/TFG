import 'package:shared_preferences/shared_preferences.dart';

class MySharedPreferences {

  Future<Set<String>> getKeys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final value = prefs.getKeys();
    print("got ${value.length} results");
    return value;
  }

  Future getForm(String key) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key) ?? 0;
    print('read: $value');
    return value;
  }

  deleteForm(String key) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
    print("deleted $key");
  }

  void saveForm(String json, String title) async{
    final prefs = await SharedPreferences.getInstance();
    final key = title;
    final value = json;
    prefs.setString(key, value);
    print('saved $value');
  }

  void saveName(String name) async{
    final prefs = await SharedPreferences.getInstance();
    final key = 'userName';
    final value = name;
    prefs.setString(key, value);
    print('saved $value');
  }
}