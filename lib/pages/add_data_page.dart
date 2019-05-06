import 'package:flutter/material.dart';
import 'package:iot_ui/services/pubsubHandler.dart';

class AddDataPage extends StatefulWidget {
  @override
  _AddDataPageState createState() => _AddDataPageState();
}

class _AddDataPageState extends State<AddDataPage> {
  TextEditingController systemController = TextEditingController();
  TextEditingController deviceIdController = TextEditingController();
  TextEditingController deviceTypeController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  String dataType;
  TextEditingController fieldNameController = TextEditingController();
  TextEditingController dataController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Software for IOT'),
        ),
        body: Container(
            padding: EdgeInsets.all(16.0),
            child: new Form(
              child: new ListView(shrinkWrap: true, children: _showForm()),
            )));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    systemController.dispose();
    deviceIdController.dispose();
    deviceTypeController.dispose();
    timeController.dispose();
    fieldNameController.dispose();
    dataController.dispose();
    super.dispose();
  }

  List<Widget> _showForm() {
    var children = <Widget>[];
    children.add(Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: TextField(
          controller: systemController,
          decoration: InputDecoration(
            labelText: 'system',
            hintText: 'system',
          ),
        )));

    children.add(Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: TextField(
          controller: deviceIdController,
          decoration: InputDecoration(
            labelText: 'device id',
            hintText: 'device id',
          ),
        )));

    children.add(Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: TextField(
          controller: deviceTypeController,
          decoration: InputDecoration(
            labelText: 'device type',
            hintText: 'device type',
          ),
        )));
    children.add(Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: Text("data type")));
    children.add(Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 1.0, 0.0, 0.0),
        child: DropdownButton<String>(
          value: dataType,
          onChanged: (v) => setState(() {
                dataType = v;
              }),
          items: <String>['text', 'number', 'video', 'audio', 'image']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        )));

    children.add(Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: TextField(
          controller: fieldNameController,
          decoration: InputDecoration(
            labelText: 'field name',
            hintText: 'field name',
          ),
        )));

    children.add(Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: TextField(
          controller: dataController,
          decoration: InputDecoration(
            labelText: 'data',
            hintText: 'data',
          ),
        )));

    children.add(Padding(
        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
        child: MaterialButton(
            elevation: 5.0,
            minWidth: 200.0,
            height: 42.0,
            color: Colors.blue,
            child: Text("Add data",
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () {
              PubsubHandler.sendToPubSub(
                  systemController.text,
                  deviceIdController.text,
                  deviceTypeController.text,
                  DateTime.now(),
                  dataType,
                  fieldNameController.text,
                  dataController.text);
            })));

    return children;
  }
}
