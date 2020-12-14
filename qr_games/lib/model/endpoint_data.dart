class EndpointData {
  EndpointData(this.name, this.id, this.token, this.isIncoming, this.uuid);

  String name;
  String id;
  String token;
  bool isIncoming;
  String uuid;

  @override
  String toString() {
    return 'name: ' + name +
        '\nid: ' + id +
        '\ntoken: ' + token +
        '\nisIncoming: ' + isIncoming.toString() +
        '\nUUID: ' + uuid;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'token' : token,
      'isIncoming' : isIncoming,
      'uuid' : uuid
    };
  }

  EndpointData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    token = json['token'];
    isIncoming = json['isIncoming'];
    uuid = json['uuid'];
  }
}