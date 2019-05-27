import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iot_ui/data_model/DataEntry.dart';
import 'package:iot_ui/data_model/FileDataEntry.dart';
import 'package:iot_ui/data_model/NumberDataEntry.dart';
import 'package:iot_ui/data_model/TextDataEntry.dart';
import 'package:iot_ui/widgets/maps.dart';
import 'package:iot_ui/widgets/pending_action.dart';
import 'package:iot_ui/widgets/player_widget.dart';
import 'package:iot_ui/widgets/video_widget.dart';
import 'package:tuple/tuple.dart';

class DataEntryCard extends StatelessWidget {
  final DataEntry dataEntry;

  DataEntryCard({@required this.dataEntry});

  Tuple2<Widget, String> _getIconAndData(DataEntry currentDataEntry) {
    if (currentDataEntry is TextDataEntry) {
      return Tuple2<Widget, String>(
          Icon(
            const IconData(57560, fontFamily: 'MaterialIcons'),
            size: 40,
          ),
          currentDataEntry.data);
    } else if (currentDataEntry is NumberDataEntry) {
      return Tuple2<Widget, String>(
          Icon(
            const IconData(57922, fontFamily: 'MaterialIcons'),
            size: 40,
          ),
          currentDataEntry.data.toString());
    } else if (currentDataEntry is FileDataEntry) {
      if (currentDataEntry.type == DataEntryType.image) {
        return Tuple2<Widget, String>(
            Icon(
              const IconData(58356, fontFamily: 'MaterialIcons'),
              size: 40,
            ),
            currentDataEntry.fileName);
      } else if (currentDataEntry.type == DataEntryType.audio) {
        return Tuple2<Widget, String>(
            Icon(const IconData(58273, fontFamily: 'MaterialIcons'), size: 40),
            currentDataEntry.fileName);
      } else if (currentDataEntry.type == DataEntryType.video) {
        return Tuple2<Widget, String>(
            Icon(const IconData(57419, fontFamily: 'MaterialIcons'), size: 40),
            currentDataEntry.fileName);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var currentDataEntry = dataEntry;
    Tuple2<Widget, String> iconAndData = _getIconAndData(currentDataEntry);
    Widget trailing = iconAndData.item1;
    String dataValue = iconAndData.item2;

    var children3 = <Widget>[
      Container(
        width: 0.5 * MediaQuery.of(context).size.width,
        child: Text(
          currentDataEntry.fieldName + ":" + dataValue,
          style: TextStyle(
              fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ];

    if (currentDataEntry.location != null) {
      children3.add(Container(
        width: 30,
        child: MaterialButton(
          child: Icon(Icons.map, size: 30),
          onPressed: () {
            _buildMapsDialog(context, currentDataEntry);
          },
        ),
      ));
    }
    var children2 = <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: children3,
      ),
      Text(
        "System: " + currentDataEntry.systemName,
        style: TextStyle(fontSize: 21, color: Colors.white),
      ),
      Text(
        "Device Id: " + currentDataEntry.deviceId,
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      Text(
        "Device type: " + currentDataEntry.deviceType,
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      Text(
        DateFormat("yyyy.MM.dd  'at' HH:mm").format(currentDataEntry.time),
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    ];

    if (currentDataEntry is FileDataEntry) {
      if (currentDataEntry.type == DataEntryType.image) {
        Widget imageWidget;
        children2.add(MaterialButton(
          child: Container(
              height: 100,
              width: 100,
              child: FutureBuilder<dynamic>(
                  future: currentDataEntry.url,
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return PendingAction();
                      case ConnectionState.active:
                      case ConnectionState.waiting:
                        return PendingAction();
                      case ConnectionState.done:
                        if (snapshot.hasError)
                          return Text('Error: ${snapshot.error}');
                        imageWidget = Image.network(snapshot.data);
                        return imageWidget;
                    }
                  })),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => _buildImageDialog(
                    context, currentDataEntry.fileName, imageWidget));
          },
        ));
      } else if (currentDataEntry.type == DataEntryType.audio) {
        children2.add(Container(
            height: 100,
            width: 200,
            child: FutureBuilder<dynamic>(
                future: currentDataEntry.url,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return PendingAction();
                    case ConnectionState.active:
                    case ConnectionState.waiting:
                      return PendingAction();
                    case ConnectionState.done:
                      if (snapshot.hasError)
                        return Text('Error: ${snapshot.error}');
                      return PlayerWidget(url: snapshot.data);
                  }
                })));
      } else if (currentDataEntry.type == DataEntryType.video) {
        Widget videoWidget;
        children2.add(MaterialButton(
          child: Container(
              height: 100,
              width: 100,
              child: FutureBuilder<dynamic>(
                  future: currentDataEntry.url,
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return PendingAction();
                      case ConnectionState.active:
                      case ConnectionState.waiting:
                        return PendingAction();
                      case ConnectionState.done:
                        if (snapshot.hasError)
                          return Text('Error: ${snapshot.error}');
                        videoWidget = VideoWidget(url: snapshot.data);
                        return videoWidget;
                    }
                  })),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => _buildImageDialog(
                    context, currentDataEntry.fileName, videoWidget));
          },
        ));
      }
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: Colors.blue[300],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                height: 70,
                width: 70,
                child: trailing,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageDialog(
      BuildContext context, String imageName, Widget imageWidget) {
    return AlertDialog(
      title: Center(child: Text(imageName)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[imageWidget],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Go back'),
        ),
      ],
    );
  }

  Widget _buildMapsDialog(BuildContext context, DataEntry dataEntry) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Center(child: Text(dataEntry.deviceId)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      height: 300,
                      width: 300,
                      child: Maps(dataEntry: dataEntry)),
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  textColor: Theme.of(context).primaryColor,
                  child: const Text('Go back'),
                ),
              ],
            ));
  }
}
