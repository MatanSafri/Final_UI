import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:iot_ui/blocs/dates_filtering_bloc.dart';

class DatesFiltering extends StatefulWidget {
  @override
  _DateFilteringState createState() =>
      _DateFilteringState(onStartDateChange, onEndDateChange);

  final Function(DateTime value) onStartDateChange;
  final Function(DateTime value) onEndDateChange;

  DatesFiltering(
      {@required this.onEndDateChange, @required this.onStartDateChange});
}

class _DateFilteringState extends State<DatesFiltering> {
  DatesFilteringBloc _bloc;
  _DateFilteringState(Function(DateTime value) onStartDateChange,
      Function(DateTime value) onEndDateChange) {
    _bloc = DatesFilteringBloc();

    if (onStartDateChange != null)
      _bloc.startTimeDateStream.listen((onData) {
        onStartDateChange(onData);
      });

    if (onEndDateChange != null)
      _bloc.endTimeDateStream.listen((onData) {
        onEndDateChange(onData);
      });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        trailing: Icon(IconData(59670, fontFamily: 'MaterialIcons')),
        title: Center(child: Text("Dates")),
        children: <Widget>[
          FlatButton(
              onPressed: () {
                DatePicker.showDateTimePicker(context, showTitleActions: true,
                    onChanged: (date) {
                  print('change $date');
                }, onConfirm: (date) {
                  print('confirm $date');
                  _bloc.startTimeDateSink.add(date);
                }, currentTime: DateTime.now(), locale: LocaleType.en);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Start Date', style: TextStyle(color: Colors.blue)),
                  StreamBuilder<DateTime>(
                      stream: _bloc.startTimeDateStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<DateTime> snapshot) {
                        if (snapshot.hasError)
                          return new Text('${snapshot.error}');
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return Text("");
                        if (snapshot.data == null) return Text("");
                        return Center(
                          child: Text(DateFormat("yyyy.MM.dd  'at' HH:mm")
                              .format(snapshot.data)),
                        );
                      }),
                ],
              )),
          FlatButton(
              onPressed: () {
                DatePicker.showDateTimePicker(context, showTitleActions: true,
                    onChanged: (date) {
                  print('change $date');
                }, onConfirm: (date) {
                  print('confirm $date');
                  _bloc.endTimeDateSink.add(date);
                }, currentTime: DateTime.now(), locale: LocaleType.en);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('End Date', style: TextStyle(color: Colors.blue)),
                  StreamBuilder<DateTime>(
                      stream: _bloc.endTimeDateStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<DateTime> snapshot) {
                        if (snapshot.hasError)
                          return new Text('${snapshot.error}');
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return Text("");
                        if (snapshot.data == null) return Text("");
                        return Center(
                          child: Text(DateFormat("yyyy.MM.dd  'at' HH:mm")
                              .format(snapshot.data)),
                        );
                      }),
                ],
              )),
          FlatButton(
              child: Text("Clear"),
              onPressed: () {
                _bloc.startTimeDateSink.add(null);
                _bloc.endTimeDateSink.add(null);
              }),
        ]);
  }
}
