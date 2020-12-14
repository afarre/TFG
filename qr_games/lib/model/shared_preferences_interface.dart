class IPreferences {
  Future<Set<String>> getKeys() async {}
  Future getForm(String key) async{}
  deleteForm(String key) async{}
  void saveForm(String json, String title) async{}
  void saveName(String name) async{}
}