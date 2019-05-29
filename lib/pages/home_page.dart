import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iot_ui/blocs/authentication/authentication_bloc.dart';
import 'package:iot_ui/blocs/bloc_helpers/bloc_provider.dart';
import 'package:iot_ui/blocs/data_display_bloc.dart';
import 'package:iot_ui/data_model/DataEntry.dart';
import 'package:iot_ui/pages/charts_page_page.dart';
import 'package:iot_ui/widgets/dataEntry_card.dart';
import 'package:iot_ui/widgets/dates_filtering.dart';
import 'package:iot_ui/widgets/filtering.dart';
import 'package:iot_ui/widgets/logout_button.dart';
import 'package:iot_ui/widgets/maps.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Prevents the use of the "back" button
  Future<bool> _onWillPopScope() async {
    return false;
  }

  @override
  void initState() {
    super.initState();
    AuthenticationBloc bloc = BlocProvider.of<AuthenticationBloc>(context);
    _dataDisplayBloc = DataDisplayBloc(bloc.lastState.userId);
  }

  @override
  void dispose() {
    _dataDisplayBloc?.dispose();
    super.dispose();
  }

  DataDisplayBloc _dataDisplayBloc;

  void _buildDialog(BuildContext context, String name, List<Widget> widget) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Center(child: Text(name)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget,
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

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];

    children.add(ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 0.75 * MediaQuery.of(context).size.height,
      ),
      child: SingleChildScrollView(
        child: ExpansionTile(
            title: Center(child: Text("Filtering Options")),
            children: <Widget>[
              Filtering(
                titleName: "Systems",
                stream: _dataDisplayBloc.userSystemNamesStream,
                onSelectionChange: _dataDisplayBloc.onSystemSelectionChanged,
              ),
              DatesFiltering(
                onStartDateChange: _dataDisplayBloc.onStartDateTimeChange,
                onEndDateChange: _dataDisplayBloc.onEndDateTimeChange,
              ),
              Filtering(
                titleName: "Data types",
                stream: _dataDisplayBloc.dataTypesStream,
                onSelectionChange: _dataDisplayBloc.onDataTypesSelectionChanged,
              ),
              Filtering(
                titleName: "Devices",
                stream: _dataDisplayBloc.systemDevicesStream,
                onSelectionChange: _dataDisplayBloc.onDevicesSelectionChanged,
              ),
              Filtering(
                titleName: "Devices types",
                stream: _dataDisplayBloc.systemDevicesTypesStream,
                onSelectionChange:
                    _dataDisplayBloc.onDeviceTypesSelectionChanged,
              ),
              Filtering(
                titleName: "Field names",
                stream: _dataDisplayBloc.systemFieldsNamesStream,
                onSelectionChange:
                    _dataDisplayBloc.onFieldNamesSelectionChanged,
              ),
            ]),
      ),
    ));

    children.add(MaterialButton(
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)),
        elevation: 5.0,
        minWidth: 200.0,
        height: 42.0,
        color: Colors.blue,
        child: Text("Get Data",
            style: TextStyle(fontSize: 20.0, color: Colors.white)),
        onPressed: () {
          _dataDisplayBloc.getData();
        }));

    children.add(Expanded(
      child: StreamBuilder<List<DataEntry>>(
          stream: _dataDisplayBloc.systemsDataStream,
          builder:
              (BuildContext context, AsyncSnapshot<List<DataEntry>> snapshot) {
            if (snapshot.hasError)
              return Text('${snapshot.error}');
            else if (snapshot.connectionState == ConnectionState.waiting)
              return Container();
            if (!snapshot.hasData) return Container();

            return DefaultTabController(
              length: 3,
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(50.0),
                  child: AppBar(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    automaticallyImplyLeading: false,
                    bottom: TabBar(
                      tabs: [
                        Tab(icon: Icon(Icons.list)),
                        Tab(icon: Icon(Icons.insert_chart)),
                        Tab(icon: Icon(Icons.map)),
                      ],
                    ),
                  ),
                ),
                body: TabBarView(
                  children: [
                    ListView.builder(
                        shrinkWrap: false,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, index) {
                          return DataEntryCard(dataEntry: snapshot.data[index]);
                        }),
                    ListView(
                      children: <Widget>[
                        ChartsPage(dataEntries: snapshot.data),
                      ],
                    ),
                    ListView(children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Maps(
                            dataEntries: snapshot.data
                                .where(
                                    (dataEntry) => dataEntry.location != null)
                                .toList()),
                      ),
                    ]),
                  ],
                ),
              ),
            );
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
                  MaterialButton(
                    child: Icon(Icons.system_update_alt),
                    onPressed: () {
                      _buildDialog(
                          context, "Choose systems of interst", <Widget>[
                        Filtering(
                          titleName: "All systems",
                          stream: _dataDisplayBloc.allSystemNamesStream,
                          onSelectionChange:
                              _dataDisplayBloc.onUserSystemsSelectionChanged,
                        ),
                        MaterialButton(
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                            elevation: 5.0,
                            minWidth: 200.0,
                            height: 42.0,
                            color: Colors.blue,
                            child: Text("Update systems of interst",
                                style: TextStyle(
                                    fontSize: 20.0, color: Colors.white)),
                            onPressed: () async {
                              _dataDisplayBloc.changeUserSystems();
                            })
                      ]);
                    },
                  ),
                  LogOutButton(),
                ],
              ),
              body: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(children: children),
              ))),
    );
  }
}
