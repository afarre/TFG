class AdvertiserData {
  AdvertiserData(this.name, this.id, this.serviceId);

  String name;
  String id;
  String serviceId;

  @override
  String toString() {
    return 'name: ' + name +
        '\nid: ' + id +
        '\ntoken: ' + serviceId;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'token' : serviceId
    };
  }

  AdvertiserData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    serviceId = json['serviceId'];
  }
}