import 'package:flutter/material.dart';
import 'package:iot_ui/blocs/filltering_bloc.dart';
import 'package:iot_ui/widgets/pending_action.dart';

class Filtering extends StatefulWidget {
  @override
  _FilteringState createState() => _FilteringState(stream, onSelectionChange);

  final String titleName;
  final Stream<List<String>> stream;
  final Function(List<String> value) onSelectionChange;

  Filtering(
      {@required this.titleName,
      @required this.stream,
      @required this.onSelectionChange});
}

class _FilteringState extends State<Filtering> {
  FilteringBloc _bloc;
  _FilteringState(Stream<List<String>> stream,
      Function(List<String> value) onSelectionChange) {
    _bloc = FilteringBloc(stream);

    if (onSelectionChange != null)
      _bloc.selectedItems.listen((onData) {
        onSelectionChange(onData);
      });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        title: Center(child: Text(widget.titleName)),
        children: <Widget>[
          StreamBuilder<List<String>>(
              stream: _bloc.allItems,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(systemName),
                        StreamBuilder<bool>(
                            stream:
                                _bloc.checkStateSystemNamesStream[systemName],
                            initialData: false,
                            builder: (BuildContext context,
                                AsyncSnapshot<bool> snapshot) {
                              if (snapshot.hasError)
                                return new Text('${snapshot.error}');
                              return Checkbox(
                                  value: snapshot.data,
                                  onChanged: (value) {
                                    print("$systemName is $value \n");
                                    _bloc.checkStateSystemNamesSink[systemName]
                                        .add(value);
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
                _bloc.checkStateSystemNamesSink.values.forEach((sink) {
                  sink.add(false);
                });
              }),
        ]);
  }
}
