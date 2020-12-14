class EndpointData {
  EndpointData(this.name, this.id, this.token, this.isIncoming, this.UUID);

  final String name;
  final String id;
  final String token;
  bool isIncoming;
  String UUID;

  @override
  String toString() {
    return 'name: ' + name +
        '\nid: ' + id +
        '\ntoken: ' + token +
        '\nisIncoming: ' + isIncoming.toString() +
        '\nUUID: ' + UUID;
  }
}