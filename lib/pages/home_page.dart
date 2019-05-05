import 'package:flutter/material.dart';
import 'package:iot_ui/blocs/bloc_widgets/bloc_state_builder.dart';
import 'package:iot_ui/blocs/data_display/data_display_bloc.dart';
import 'package:iot_ui/blocs/data_display/data_display_event.dart';
import 'package:iot_ui/blocs/data_display/data_display_state.dart';
import 'package:iot_ui/widgets/logout_button.dart';
import 'package:iot_ui/widgets/pending_action.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

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
    children.add(ExpansionTile(
      title: Center(child: Text("Filtering Options")),
      children: <Widget>[
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Expanded(
              flex: 1,
              child: ExpansionTile(
                  title: Center(child: Text("Systems")),
                  children: <Widget>[
                    StreamBuilder<List<String>>(
                        stream: _dataDisplayBloc.systemNamesStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<String>> snapshot) {
                          if (snapshot.hasError)
                            return new Text('${snapshot.error}');
                          else if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return Container(
                                child: PendingAction(),
                                height: 120); //Container();
                          List<String> systemsNames = List<String>();
                          if (snapshot.hasData) {
                            systemsNames.addAll(snapshot.data.reversed);
                            var systemsCheckBox = <Widget>[];
                            systemsNames.forEach((systemName) {
                              systemsCheckBox.add(Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(systemName),
                                  StreamBuilder<bool>(
                                      stream: _dataDisplayBloc
                                              .checkStateSystemNamesStream[
                                          systemName],
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
                  ])),
          Expanded(
              flex: 1,
              child: ExpansionTile(
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
                                  else if (snapshot.connectionState ==
                                      ConnectionState.waiting) return Text("");
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
                                  else if (snapshot.connectionState ==
                                      ConnectionState.waiting) return Text("");
                                  return Center(
                                    child: Text(
                                        DateFormat("yyyy.MM.dd  'at' HH:mm")
                                            .format(snapshot.data)),
                                  );
                                }),
                          ],
                        ))
                  ]))
        ])
      ],
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

    children.add(BlocEventStateBuilder<DataDisplayEvent, DataDisplayState>(
        bloc: _dataDisplayBloc,
        builder: (BuildContext context, DataDisplayState state) {
          return StreamBuilder<List<Map<String, dynamic>>>(
              stream: _dataDisplayBloc.systemsDataStream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasError)
                  return Text('${snapshot.error}');
                else if (snapshot.connectionState == ConnectionState.waiting)
                  return Container(
                      child: PendingAction(), height: 120); //Container();
                if (!snapshot.hasData) return Container();
                snapshot.data.forEach((item) {
                  print("${item.toString()}\n");
                });
                //print("${snapshot.data.toString()}\n");
                return Container(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, index) {
                          var currentDoc = snapshot.data[index];
                          var dataWidgets = <Widget>[];
                          //bug i cant do foreach
                          for (var key in currentDoc.keys) {
                            dataWidgets.add(Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text(key.toString() + " : ")
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(currentDoc[key].toString())
                                  ],
                                )
                              ],
                            ));
                          }
                          return ExpansionTile(
                              title: Text(currentDoc["device_type"].toString()),
                              children:
                                  dataWidgets //<Widget>[Text(currentDoc.toString())],
                              );
                        }));
              });
        }));

    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: SafeArea(
          child: Scaffold(
              appBar: AppBar(
                title: Text('Home Page'),
                leading: Container(),
                actions: <Widget>[
                  LogOutButton(),
                ],
              ),
              body: Container(
                padding: EdgeInsets.all(16.0),
                child: new ListView(shrinkWrap: true, children: children),
              ))
          //_showBody(context)),
          ),
    );
  }
}
