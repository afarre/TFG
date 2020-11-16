import 'package:flutter/material.dart';

class EndpointData {
  EndpointData(this.name, this.id, this.token, this.isIncoming);

  final String name;
  final String id;
  final String token;
  bool isIncoming;

  @override
  String toString() {
    return 'name: ' + name +
        '\nid: ' + id +
        '\ntoken: ' + token +
        '\nisIncoming: ' + isIncoming.toString();
  }
}

class EndpointList extends StatefulWidget {
  EndpointList({Key key}) : super(key: key);

  final List<EndpointData> endpointList = <EndpointData>[];
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Connected devices'),
        ),
        body: ListView.builder(
          itemCount: endpointList.length,
          itemBuilder: (context, index){
            final endpoint = endpointList[index];
            return ListTile(
              title: Text(
                endpoint.name,
                style: Theme.of(context).textTheme.headline5,
              ),
              onTap: () => onTapped(index, context),
            );
          },
        )
    );
  }

  BoxConstraints setConstraints(bool complete){
    if(complete) {
      return BoxConstraints(
        minWidth: 30,
        minHeight: 30,
        maxWidth: 40,
        maxHeight: 40,
      );
    } else {
      return BoxConstraints(
        minWidth: 30,
        minHeight: 30,
        maxWidth: 35,
        maxHeight: 35,
      );
    }
  }

  void insertEndpoint(EndpointData endpointData){
    endpointList.add(endpointData);
    print(endpointList.toString());
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }

  onTapped(int index, BuildContext context) {
    print("tapped: " + context.toString() + "; index: " + index.toString());
  }

}
