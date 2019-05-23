import 'package:flutter/material.dart';
import 'package:iot_ui/blocs/charts_bloc.dart';
import 'package:iot_ui/data_model/DataEntry.dart';
import 'package:iot_ui/widgets/pie_chart.dart';
import 'package:iot_ui/widgets/time_chart.dart';

class ChartsPage extends StatefulWidget {
  final List<DataEntry> dataEntries;

  ChartsPage({@required this.dataEntries});

  @override
  _ChartsPageState createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  ChartsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ChartsBloc();
  }

  @override
  Widget build(BuildContext context) {
    _bloc = ChartsBloc();
    return Column(
      children: <Widget>[
        StreamBuilder<String>(
            stream: _bloc.chartType,
            initialData: "Pie",
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              List<Widget> charts = List<Widget>();

              charts.add(DropdownButton<String>(
                value: snapshot.data,
                items: <String>["Pie", "Time"]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: _bloc.onchartTypeChanged,
              ));

              if (snapshot.data == "Pie") {
                charts.add(StreamBuilder<String>(
                    stream: _bloc.field,
                    initialData: "Device Id",
                    builder: (BuildContext context,
                        AsyncSnapshot<String> snapshot2) {
                      return Column(
                        children: <Widget>[
                          DropdownButton<String>(
                            value: snapshot2.data,
                            items: <String>[
                              "System name",
                              "Device Id",
                              "Field name",
                              "Data type",
                              "Device type"
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: _bloc.onFieldChanged,
                          ),
                          Container(
                            height: 300,
                            child: PieChart(
                                chartField: snapshot2.data,
                                dataEntries: widget.dataEntries),
                          )
                        ],
                      );
                    }));

                //charts.add();
              } else if (snapshot.data == "Time") {
                charts.add(Container(
                    height: 300,
                    child: TimeChart(
                      dataEntries: widget.dataEntries,
                    )));
              }
              return Column(children: charts);
            }),
      ],
    );
  }
}
