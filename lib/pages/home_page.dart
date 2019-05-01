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

  Widget _showBody(BuildContext context, DataDisplayState state) {
    var children = <Widget>[];

    children.add(MaterialButton(
        elevation: 5.0,
        minWidth: 200.0,
        height: 42.0,
        color: Colors.blue,
        child: Text("Check",
            style: new TextStyle(fontSize: 20.0, color: Colors.white)),
        onPressed: () {
          //_dataDisplayBloc.emitEvent(InitDataDispayEvent());
          //await for (var data in DAL.getSystemsNames()) print("$data\n");
          //_showMultiSelect(context);
        }));

    // List<Map> dataSource = List<Map>();

    // state.systemNames.forEach((systemName) {
    //   int index = 1;
    //   dataSource.add({"display": systemName, "value": index++});
    // });

    // children.add(MultiSelect(
    //     autovalidate: true,
    //     titleText: "Select system",
    //     validator: (value) {
    //       if (value == null) {
    //         return 'Please select one or more option(s)';
    //       }
    //     },
    //     dataSource: dataSource,
    //     textField: 'display',
    //     valueField: 'value',
    //     filterable: true,
    //     required: true,
    //     onSaved: (value) {
    //       print("bala\n");
    //     }));
  }

  List<Widget> _displayData(QuerySnapshot snapshot) {
    var dataWidgets = <Widget>[];
    DAL.getSystemDataFromQuery(snapshot).forEach((dataEntry) {
      dataWidgets.add(Text(dataEntry.toString()));
    });
    return dataWidgets;
  }

  DataDisplayBloc _dataDisplayBloc;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    // children.add(BlocEventStateBuilder<DataDisplayEvent, DataDisplayState>(
    //     bloc: _dataDisplayBloc,
    //     builder: (BuildContext context, DataDisplayState state) {
    //       //if (state.isLoading) return PendingAction();
    //       return _showBody(context, state);
    //     }));

    children.add(StreamBuilder<QuerySnapshot>(
        stream: _dataDisplayBloc.systemNamesStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError)
            return new Text('${snapshot.error}');
          else if (snapshot.connectionState == ConnectionState.waiting)
            return Container(); //PendingAction();

          List<String> systemsNames = List<String>();
          List<Map> dataSource = List<Map>();
          if (snapshot.hasData) {
            systemsNames.addAll(DAL.getSystemNamesFromQuery(snapshot.data));
            int index = 0;
            systemsNames.forEach((systemName) {
              dataSource.add({"display": systemName, "value": index++});
            });
          }
          return new Form(
              key: _formKey,
              autovalidate: true,
              child: MultiSelect(
                  autovalidate: true,
                  titleText: "Select system",
                  validator: (value) {
                    if (value == null) {
                      return 'Please select one or more option(s)';
                    }
                  },
                  dataSource: dataSource,
                  textField: 'display',
                  valueField: 'value',
                  filterable: true,
                  required: true,
                  onSaved: (value) {
                    List<String> selectedSystems = List<String>();
                    value.forEach((i) {
                      selectedSystems.add(systemsNames.elementAt(i));
                    });
                    print("$selectedSystems\n");
                    _dataDisplayBloc.emitEvent(
                        ChangeSystemsSelection(newSystems: selectedSystems));
                  }));
        }));

    children.add(MaterialButton(
        elevation: 5.0,
        minWidth: 200.0,
        height: 42.0,
        color: Colors.blue,
        child: Text("Get Data",
            style: TextStyle(fontSize: 20.0, color: Colors.white)),
        onPressed: () {
          final FormState form = _formKey.currentState;
          form.save();
        }));

    children.add(StreamBuilder<QuerySnapshot>(
        stream: _dataDisplayBloc.systemsDataStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          print("data stream is on\n");
          if (snapshot.hasError)
            return Text('${snapshot.error}');
          else if (snapshot.connectionState == ConnectionState.waiting)
            return Container(); //PendingAction();
          print("data stream got new data\n");
          print("${snapshot.data.documents.length}\n");
          DAL.getSystemDataFromQuery(snapshot.data).forEach((d) {
            print("$d");
          });
          return Text(snapshot.data.documents.first.data
              .toString()); //ListView(children: _displayData(snapshot.data)); //Container();
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
