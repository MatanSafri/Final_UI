import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iot_ui/blocs/bloc_widgets/bloc_state_builder.dart';
import 'package:iot_ui/blocs/data_display/data_display_bloc.dart';
import 'package:iot_ui/blocs/data_display/data_display_event.dart';
import 'package:iot_ui/blocs/data_display/data_display_state.dart';
import 'package:iot_ui/services/DAL.dart';
import 'package:iot_ui/widgets/logout_button.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:iot_ui/widgets/pending_action.dart';

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
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    // children.add(
    //   StreamBuilder<List<String>>(
    //     stream: _dataDisplayBloc.systemNamesStream,
    //     builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
    //       if (snapshot.hasError)
    //         return new Text('${snapshot.error}');
    //       else if (snapshot.connectionState == ConnectionState.waiting)
    //         return Container(
    //             child: PendingAction(), height: 120); //Container();
    //       List<String> systemsNames = List<String>();
    //       List<Map> dataSource = List<Map>();
    //       if (snapshot.hasData) {
    //         systemsNames.addAll(snapshot.data.reversed);
    //         int index = 0;
    //         systemsNames.forEach((systemName) {
    //           dataSource.add({"display": systemName, "value": index++});
    //         });
    //       }
    //       var getDataChildrens = <Widget>[];

    //       getDataChildrens.add(Form(
    //           key: _formKey,
    //           autovalidate: true,
    //           child: MultiSelect(
    //               autovalidate: true,
    //               titleText: "Select system",
    //               validator: (value) {
    //                 if (value == null) {
    //                   return 'Please select one or more option(s)';
    //                 }
    //               },
    //               dataSource: dataSource,
    //               textField: 'display',
    //               valueField: 'value',
    //               filterable: true,
    //               required: true,
    //               onSaved: (value) {
    //                 List<String> selectedSystems = List<String>();
    //                 value.forEach((i) {
    //                   selectedSystems.add(systemsNames.elementAt(i));
    //                 });
    //                 print("$selectedSystems\n");
    //                 _dataDisplayBloc.emitEvent(
    //                     ChangeSystemsSelection(newSystems: selectedSystems));
    //               })));
    //       getDataChildrens.add(MaterialButton(
    //           elevation: 5.0,
    //           minWidth: 200.0,
    //           height: 42.0,
    //           color: Colors.blue,
    //           child: Text("Get Data",
    //               style: TextStyle(fontSize: 20.0, color: Colors.white)),
    //           onPressed: () {
    //             final FormState form = _formKey.currentState;
    //             form.save();
    //           }));
    //       return ListView(shrinkWrap: true, children: getDataChildrens);
    //     }));

    //var getDataChildrens = <Widget>[];

    //var checkedSystems = <String>[];

    children.add(ExpansionTile(
      title: Text("Systems"),
      children: <Widget>[
        StreamBuilder<List<String>>(
            stream: _dataDisplayBloc.systemNamesStream,
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.hasError)
                return new Text('${snapshot.error}');
              else if (snapshot.connectionState == ConnectionState.waiting)
                return Container(
                    child: PendingAction(), height: 120); //Container();
              List<String> systemsNames = List<String>();
              if (snapshot.hasData) {
                systemsNames.addAll(snapshot.data.reversed);
                var systemsCheckBox = <Widget>[];

                systemsNames.forEach((systemName) {
                  systemsCheckBox.add(Row(
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
                                      .checkStateSystemNamesSink[systemName]
                                      .add(value);
                                  _dataDisplayBloc.emitEvent(
                                      ChangeSystemSelection(systemName, value));
                                });
                          }),
                    ],
                  ));
                });
                return Column(children: systemsCheckBox);
              }
            })
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
