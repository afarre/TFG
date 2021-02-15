class AdvertiserData {
  AdvertiserData(this.name, this.id, this.serviceId, this.connected);

  String name;
  String id;
  String serviceId;
  bool connected = false;

  @override
  String toString() {
    return 'name: ' + name +
        '\nid: ' + id +
        '\ntoken: ' + serviceId +
        '\nconnected: ' + connected.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'token' : serviceId,
      'connected' : connected
    };
  }

  AdvertiserData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    serviceId = json['serviceId'];
    connected = json['connected'];
  }
}