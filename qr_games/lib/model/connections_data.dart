import 'package:nearby_connections/nearby_connections.dart';

class ConnectionData {
  ConnectionData(this.id, this.status);

  final String id;
  final Status status;

  @override
  String toString() {
    return 'id: ' + id +
        '\nstatus: ' + status.toString();
  }
}