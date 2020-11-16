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

class EndpointList extends StatefulWidget{
  _EndpointList _endpointList = _EndpointList();


  @override
  State<StatefulWidget> createState() => _endpointList;

  insertEndpoint(EndpointData data){
    _endpointList.insertEndpoint(data);
  }

}

class _EndpointList extends State<EndpointList>{
  final List<EndpointData> endpointList = <EndpointData>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Connected devices'),
        ),
        body: ListView.builder(
          itemCount: endpointList.length,
          itemBuilder: (context, index){
            /*
            final endpoint = endpointList[index];
            return ListTile(
              title: Text(
                endpoint.name,
                style: Theme.of(context).textTheme.headline5,
              ),
              onTap: () => onTapped(index, context),
            );

             */

            return Container(
              //color: Colors.amber[colorCodes[index]],
              child: Center(
                  child: Container(
                    child: fillSingleCell(endpointList[index]),
                  )),
            );
          },
        )
    );
  }

  insertEndpoint(EndpointData endpointData){
    endpointList.add(endpointData);
    print(endpointList.toString());
  }

  fillSingleCell(EndpointData data) {
    //TODO: Colocar cada element al lloc corresponent
    return Container(
        child: Column(
          children: <Widget>[
            Text(insertText(data.name)),
            Text(insertText(data.token)),
            Text(insertText(data.id)),
            Text(insertText(data.isIncoming.toString()))
          ],
        )
    );
  }

  insertText(String text) {
    if (text != null) {
      return text;
    } else {
      return "No specific time";
    }
  }
}