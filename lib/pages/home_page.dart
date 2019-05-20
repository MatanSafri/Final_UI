import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iot_ui/blocs/bloc_widgets/bloc_state_builder.dart';
import 'package:iot_ui/blocs/data_display/data_display_bloc.dart';
import 'package:iot_ui/blocs/data_display/data_display_event.dart';
import 'package:iot_ui/blocs/data_display/data_display_state.dart';
import 'package:iot_ui/data_model/DataEntry.dart';
import 'package:iot_ui/data_model/FileDataEntry.dart';
import 'package:iot_ui/data_model/NumberDataEntry.dart';
import 'package:iot_ui/data_model/TextDataEntry.dart';
import 'package:iot_ui/widgets/logout_button.dart';
import 'package:iot_ui/widgets/maps.dart';
import 'package:iot_ui/widgets/pending_action.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:iot_ui/widgets/video_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:iot_ui/widgets/player_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ///
  /// Prevents the use of the "back" button
  ///
  Future<bool> _onWillPopScope() async {
    return false;
  }

  @override
  void initState() {
    super.initState();
    _dataDisplayBloc = DataDisplayBloc();
    _dataDisplayBloc.emitEvent(InitDataDisplay());
  }

  @override
  void dispose() {
    _dataDisplayBloc?.dispose();
    super.dispose();
  }

  DataDisplayBloc _dataDisplayBloc;
  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    children.add(ConstrainedBox(
      constraints: BoxConstraints(
        //minHeight: 5.0,
        // minWidth: 5.0,
        maxHeight: 0.5 * MediaQuery.of(context).size.height,
        //maxWidth: 30.0,
      ),
      child: SingleChildScrollView(
        child: ExpansionTile(
            title: Center(child: Text("Filtering Options")),
            children: <Widget>[
              ExpansionTile(title: Center(child: Text("Systems")), children: <
                  Widget>[
                StreamBuilder<List<String>>(
                    stream: _dataDisplayBloc.systemNamesStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<String>> snapshot) {
                      if (snapshot.hasError)
                        return new Text('${snapshot.error}');
                      else if (snapshot.connectionState ==
                          ConnectionState.waiting)
                        return Container(
                            child: PendingAction(), height: 120); //Container();
                      List<String> systemsNames = List<String>();
                      if (snapshot.hasData) {
                        systemsNames.addAll(snapshot.data.reversed);
                        var systemsCheckBox = <Widget>[];
                        systemsNames.forEach((systemName) {
                          systemsCheckBox.add(Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(systemName),
                              StreamBuilder<bool>(
                                  stream: _dataDisplayBloc
                                      .checkStateSystemNamesStream[systemName],
                                  initialData: false,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<bool> snapshot) {
                                    if (snapshot.hasError)
                                      return new Text('${snapshot.error}');
                                    return Checkbox(
                                        value: snapshot.data,
                                        onChanged: (value) {
                                          _dataDisplayBloc
                                              .checkStateSystemNamesSink[
                                                  systemName]
                                              .add(value);
                                          _dataDisplayBloc.emitEvent(
                                              ChangeSystemSelection(
                                                  systemName, value));
                                        });
                                  }),
                            ],
                          ));
                        });
                        return Column(children: systemsCheckBox);
                      }
                    }),
                FlatButton(
                    child: Text("Clear"),
                    onPressed: () {
                      _dataDisplayBloc.checkStateSystemNamesSink.values
                          .forEach((sink) {
                        sink.add(false);
                      });
                      _dataDisplayBloc.emitEvent(ClearSystemsSelection());
                    }),
              ]),
              ExpansionTile(
                  trailing: Icon(IconData(59670, fontFamily: 'MaterialIcons')),
                  title: Center(child: Text("Dates")),
                  children: <Widget>[
                    FlatButton(
                        onPressed: () {
                          DatePicker.showDateTimePicker(context,
                              showTitleActions: true, onChanged: (date) {
                            print('change $date');
                          }, onConfirm: (date) {
                            print('confirm $date');
                            _dataDisplayBloc.startTimeDateSink.add(date);
                            _dataDisplayBloc
                                .emitEvent(ChangeStartTimeDate(date));
                          },
                              currentTime: DateTime.now(),
                              locale: LocaleType.en);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Start Date',
                                style: TextStyle(color: Colors.blue)),
                            StreamBuilder<DateTime>(
                                stream: _dataDisplayBloc.startTimeDateStream,
                                builder: (BuildContext context,
                                    AsyncSnapshot<DateTime> snapshot) {
                                  if (snapshot.hasError)
                                    return new Text('${snapshot.error}');
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) return Text("");
                                  if (snapshot.data == null) return Text("");
                                  return Center(
                                    child: Text(
                                        DateFormat("yyyy.MM.dd  'at' HH:mm")
                                            .format(snapshot.data)),
                                  );
                                }),
                          ],
                        )),
                    FlatButton(
                        onPressed: () {
                          DatePicker.showDateTimePicker(context,
                              showTitleActions: true, onChanged: (date) {
                            print('change $date');
                          }, onConfirm: (date) {
                            print('confirm $date');
                            _dataDisplayBloc.endTimeDateSink.add(date);
                            _dataDisplayBloc.emitEvent(ChangeEndTimeDate(date));
                          },
                              currentTime: DateTime.now(),
                              locale: LocaleType.en);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('End Date',
                                style: TextStyle(color: Colors.blue)),
                            StreamBuilder<DateTime>(
                                stream: _dataDisplayBloc.endTimeDateStream,
                                builder: (BuildContext context,
                                    AsyncSnapshot<DateTime> snapshot) {
                                  if (snapshot.hasError)
                                    return new Text('${snapshot.error}');
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) return Text("");
                                  if (snapshot.data == null) return Text("");
                                  return Center(
                                    child: Text(
                                        DateFormat("yyyy.MM.dd  'at' HH:mm")
                                            .format(snapshot.data)),
                                  );
                                }),
                          ],
                        )),
                    FlatButton(
                        child: Text("Clear"),
                        onPressed: () {
                          _dataDisplayBloc.startTimeDateSink.add(null);
                          _dataDisplayBloc.endTimeDateSink.add(null);
                          _dataDisplayBloc.emitEvent(ClearDatesSelection());
                        }),
                  ]),
              ExpansionTile(
                  title: Center(child: Text("Devices")),
                  children: <Widget>[
                    StreamBuilder<List<String>>(
                        stream: _dataDisplayBloc.systemDevicesStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<String>> snapshot) {
                          if (snapshot.hasError)
                            return new Text('${snapshot.error}');
                          else if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return Container(
                                child: PendingAction(),
                                height: 120); //Container();
                          List<String> devices = List<String>();
                          if (snapshot.hasData) {
                            devices.addAll(snapshot.data.reversed);
                            var systemsCheckBox = <Widget>[];
                            devices.forEach((device) {
                              systemsCheckBox.add(Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(device),
                                  StreamBuilder<bool>(
                                      stream: _dataDisplayBloc
                                          .checkStateDevicesStream[device],
                                      initialData: false,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<bool> snapshot) {
                                        if (snapshot.hasError)
                                          return new Text('${snapshot.error}');
                                        return Checkbox(
                                            value: snapshot.data,
                                            onChanged: (value) {
                                              _dataDisplayBloc
                                                  .checkStateDevicesSink[device]
                                                  .add(value);
                                              _dataDisplayBloc.emitEvent(
                                                  ChangeDevicesSelection(
                                                      device, value));
                                            });
                                      }),
                                ],
                              ));
                            });
                            return Column(children: systemsCheckBox);
                          }
                        }),
                    FlatButton(
                        child: Text("Clear"),
                        onPressed: () {
                          _dataDisplayBloc.checkStateDevicesSink.values
                              .forEach((sink) {
                            sink.add(false);
                          });
                          _dataDisplayBloc.emitEvent(ClearDevicesSelection());
                        }),
                  ]),
              ExpansionTile(
                  title: Center(child: Text("Devices Types")),
                  children: <Widget>[
                    StreamBuilder<List<String>>(
                        stream: _dataDisplayBloc.systemDevicesTypesStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<String>> snapshot) {
                          if (snapshot.hasError)
                            return new Text('${snapshot.error}');
                          else if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return Container(
                                child: PendingAction(),
                                height: 120); //Container();
                          List<String> devicesTypes = List<String>();
                          if (snapshot.hasData) {
                            devicesTypes.addAll(snapshot.data.reversed);
                            var systemsCheckBox = <Widget>[];
                            devicesTypes.forEach((deviceType) {
                              systemsCheckBox.add(Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(deviceType),
                                  StreamBuilder<bool>(
                                      stream: _dataDisplayBloc
                                              .checkStateDevicesTypesStream[
                                          deviceType],
                                      initialData: false,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<bool> snapshot) {
                                        if (snapshot.hasError)
                                          return new Text('${snapshot.error}');
                                        return Checkbox(
                                            value: snapshot.data,
                                            onChanged: (value) {
                                              _dataDisplayBloc
                                                  .checkStateDevicesTypesSink[
                                                      deviceType]
                                                  .add(value);
                                              _dataDisplayBloc.emitEvent(
                                                  ChangeDevicesTypesSelection(
                                                      deviceType, value));
                                            });
                                      }),
                                ],
                              ));
                            });
                            return Column(children: systemsCheckBox);
                          }
                        }),
                    FlatButton(
                        child: Text("Clear"),
                        onPressed: () {
                          _dataDisplayBloc.checkStateDevicesTypesSink.values
                              .forEach((sink) {
                            sink.add(false);
                          });
                          _dataDisplayBloc
                              .emitEvent(ClearDevicesTypesSelection());
                        }),
                  ]),
              ExpansionTile(
                  title: Center(child: Text("Field Names")),
                  children: <Widget>[
                    StreamBuilder<List<String>>(
                        stream: _dataDisplayBloc.systemFieldsNamesStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<String>> snapshot) {
                          if (snapshot.hasError)
                            return new Text('${snapshot.error}');
                          else if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return Container(
                                child: PendingAction(),
                                height: 120); //Container();
                          List<String> fieldsNames = List<String>();
                          if (snapshot.hasData) {
                            fieldsNames.addAll(snapshot.data.reversed);
                            var systemsCheckBox = <Widget>[];
                            fieldsNames.forEach((fieldName) {
                              systemsCheckBox.add(Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(fieldName),
                                  StreamBuilder<bool>(
                                      stream: _dataDisplayBloc
                                              .checkStateFieldsNamesStream[
                                          fieldName],
                                      initialData: false,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<bool> snapshot) {
                                        if (snapshot.hasError)
                                          return new Text('${snapshot.error}');
                                        return Checkbox(
                                            value: snapshot.data,
                                            onChanged: (value) {
                                              _dataDisplayBloc
                                                  .checkStateFieldsNamesSink[
                                                      fieldName]
                                                  .add(value);
                                              _dataDisplayBloc.emitEvent(
                                                  ChangeFieldsNamesSelection(
                                                      fieldName, value));
                                            });
                                      }),
                                ],
                              ));
                            });
                            return Column(children: systemsCheckBox);
                          }
                        }),
                    FlatButton(
                        child: Text("Clear"),
                        onPressed: () {
                          _dataDisplayBloc.checkStateFieldsNamesSink.values
                              .forEach((sink) {
                            sink.add(false);
                          });
                          _dataDisplayBloc
                              .emitEvent(ClearFieldsNamesSelection());
                        }),
                  ]),
            ]),
      ),
    ));

    children.add(MaterialButton(
        elevation: 5.0,
        minWidth: 200.0,
        height: 42.0,
        color: Colors.blue,
        child: Text("Get Data",
            style: TextStyle(fontSize: 20.0, color: Colors.white)),
        onPressed: () {
          //print("my checked systems $checkedSystems\n");
          _dataDisplayBloc.emitEvent(DisplayData());
        }));

    //children.add(ListView(shrinkWrap: true, children: getDataChildrens));

    children.add(Expanded(
      child: BlocEventStateBuilder<DataDisplayEvent, DataDisplayState>(
          bloc: _dataDisplayBloc,
          builder: (BuildContext context, DataDisplayState state) {
            return StreamBuilder<List<DataEntry>>(
                stream: _dataDisplayBloc.systemsDataStream,
                builder: (BuildContext context,
                    AsyncSnapshot<List<DataEntry>> snapshot) {
                  if (snapshot.hasError)
                    return Text('${snapshot.error}');
                  else if (snapshot.connectionState == ConnectionState.waiting)
                    return Container();
                  if (!snapshot.hasData) return Container();
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, index) {
                        var currentDataEntry = snapshot.data[index];
                        var dataEntryWidgets = <Widget>[];
                        Widget trailing;
                        String dataValue;

                        if (currentDataEntry is TextDataEntry) {
                          trailing = Icon(
                            const IconData(57560, fontFamily: 'MaterialIcons'),
                            size: 40,
                          );
                          dataValue = currentDataEntry.data;
                        } else if (currentDataEntry is NumberDataEntry) {
                          trailing = Icon(
                            const IconData(57922, fontFamily: 'MaterialIcons'),
                            size: 40,
                          );
                          dataValue = currentDataEntry.data.toString();
                        } else if (currentDataEntry is FileDataEntry) {
                          if (currentDataEntry.type.toLowerCase() == "image") {
                            trailing = Icon(
                              const IconData(58356,
                                  fontFamily: 'MaterialIcons'),
                              size: 40,
                            );
                          } else if (currentDataEntry.type.toLowerCase() ==
                              "audio") {
                            trailing = Icon(
                                const IconData(58273,
                                    fontFamily: 'MaterialIcons'),
                                size: 40);
                          } else if (currentDataEntry.type.toLowerCase() ==
                              "video") {
                            trailing = Icon(
                                const IconData(57419,
                                    fontFamily: 'MaterialIcons'),
                                size: 40);
                          }
                          dataValue = currentDataEntry.fileName;
                        }

                        var children3 = <Widget>[
                          Container(
                            child: Text(
                              currentDataEntry.fieldName + ":" + dataValue,
                              maxLines: 3,
                              style: TextStyle(
                                  fontSize: 26,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ];

                        if (currentDataEntry.location != null) {
                          children3.add(MaterialButton(
                            child: Container(
                                height: 50, width: 50, child: Icon(Icons.map)),
                            onPressed: () {
                              _buildMapsDialog(context, currentDataEntry);
                            },
                          ));
                        }
                        var children2 = <Widget>[
                          Row(
                            children: children3,
                          ),
                          Text(
                            currentDataEntry.systemName,
                            style: TextStyle(
                                fontSize: 21,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            currentDataEntry.deviceId +
                                "," +
                                currentDataEntry.deviceType,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            DateFormat("yyyy.MM.dd  'at' HH:mm")
                                .format(currentDataEntry.time),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ];

                        if (currentDataEntry is FileDataEntry) {
                          if (currentDataEntry.type.toLowerCase() == "image") {
                            Widget imageWidget;
                            children2.add(MaterialButton(
                              child: Container(
                                  height: 100,
                                  width: 100,
                                  child: FutureBuilder<dynamic>(
                                      future: currentDataEntry.url,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<dynamic> snapshot) {
                                        switch (snapshot.connectionState) {
                                          case ConnectionState.none:
                                            return PendingAction();
                                          case ConnectionState.active:
                                          case ConnectionState.waiting:
                                            return PendingAction();
                                          case ConnectionState.done:
                                            if (snapshot.hasError)
                                              return Text(
                                                  'Error: ${snapshot.error}');
                                            imageWidget =
                                                Image.network(snapshot.data);
                                            return imageWidget;
                                        }
                                      })),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        _buildImageDialog(
                                            context,
                                            currentDataEntry.fileName,
                                            imageWidget));
                              },
                            ));
                          } else if (currentDataEntry.type.toLowerCase() ==
                              "audio") {
                            children2.add(Container(
                                height: 140,
                                width: 200,
                                child: FutureBuilder<dynamic>(
                                    future: currentDataEntry.url,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<dynamic> snapshot) {
                                      switch (snapshot.connectionState) {
                                        case ConnectionState.none:
                                          return PendingAction();
                                        case ConnectionState.active:
                                        case ConnectionState.waiting:
                                          return PendingAction();
                                        case ConnectionState.done:
                                          if (snapshot.hasError)
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          return PlayerWidget(
                                              url: snapshot.data);
                                      }
                                    })));
                          } else if (currentDataEntry.type.toLowerCase() ==
                              "video") {
                            Widget videoWidget;
                            children2.add(MaterialButton(
                              child: Container(
                                  height: 130,
                                  width: 100,
                                  child: FutureBuilder<dynamic>(
                                      future: currentDataEntry.url,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<dynamic> snapshot) {
                                        switch (snapshot.connectionState) {
                                          case ConnectionState.none:
                                            return PendingAction();
                                          case ConnectionState.active:
                                          case ConnectionState.waiting:
                                            return PendingAction();
                                          case ConnectionState.done:
                                            if (snapshot.hasError)
                                              return Text(
                                                  'Error: ${snapshot.error}');
                                            videoWidget =
                                                VideoWidget(url: snapshot.data);
                                            return videoWidget;
                                        }
                                      })),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        _buildImageDialog(
                                            context,
                                            currentDataEntry.fileName,
                                            videoWidget));
                              },
                            ));
                          }
                        }
                        dataEntryWidgets.add(Container(
                            decoration: BoxDecoration(
                                color: Colors.blue[300],
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                    color: Colors.blue[500], width: 3.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      height: 70,
                                      width: 70,
                                      child: trailing,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: children2,
                                    ),
                                  ),
                                ],
                              ),
                            )));

                        return Card(
                          child: Column(
                            children: dataEntryWidgets,
                          ),
                        );
                      });
                });
          }),
    ));

    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: SafeArea(
          child: Scaffold(
              appBar: AppBar(
                title: Center(child: Text('Software for IOT')),
                leading: Container(),
                actions: <Widget>[
                  LogOutButton(),
                ],
              ),
              body: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(children: children),
              ))),
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
