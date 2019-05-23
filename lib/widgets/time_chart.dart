import 'package:flutter/material.dart';
import 'package:iot_ui/data_model/DataEntry.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:iot_ui/data_model/NumberDataEntry.dart';

class TimeChart extends StatelessWidget {
  final List<DataEntry> dataEntries;

  TimeChart({@required this.dataEntries});

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(_getChartsData(dataEntries),
        animate: true,
        // Optionally pass in a [DateTimeFactory] used by the chart. The factory
        // should create the same type of [DateTime] as the data provided. If none
        // specified, the default creates local date time.
        // dateTimeFactory: const charts.LocalDateTimeFactory(),
        defaultRenderer: new charts.PointRendererConfig<DateTime>(),
        // It is recommended that default interactions be turned off if using bar
        // renderer, because the line point highlighter is the default for time
        // series chart.
        defaultInteractions: false,
        // If default interactions were removed, optionally add select nearest
        // and the domain highlighter that are typical for bar charts.
        //behaviors: [new charts.SelectNearest(), new charts.DomainHighlighter()],
        dateTimeFactory: const charts.LocalDateTimeFactory(),
        behaviors: [
          // Optional - Configures a [LinePointHighlighter] behavior with a
          // vertical follow line. A vertical follow line is included by
          // default, but is shown here as an example configuration.
          //
          // By default, the line has default dash pattern of [1,3]. This can be
          // set by providing a [dashPattern] or it can be turned off by passing in
          // an empty list. An empty list is necessary because passing in a null
          // value will be treated the same as not passing in a value at all.
          new charts.LinePointHighlighter(
              showHorizontalFollowLine:
                  charts.LinePointHighlighterFollowLineType.none,
              showVerticalFollowLine:
                  charts.LinePointHighlighterFollowLineType.nearest),
          // Optional - By default, select nearest is configured to trigger
          // with tap so that a user can have pan/zoom behavior and line point
          // highlighter. Changing the trigger to tap and drag allows the
          // highlighter to follow the dragging gesture but it is not
          // recommended to be used when pan/zoom behavior is enabled.
          new charts.SelectNearest(
              eventTrigger: charts.SelectionTrigger.tapAndDrag)
        ]);
  }
}

List<charts.Series<TimeSeriesData, DateTime>> _getChartsData(
    List<DataEntry> dataEntries) {
  dataEntries.sort((a, b) =>
      a.time.compareTo(b.time)); //forrEach((f){print("time : ${f.time}\n");});
  double prevData = 1;
  return [
    charts.Series<TimeSeriesData, DateTime>(
      id: 'timeChart',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (TimeSeriesData dataEntries, _) => dataEntries.time,
      measureFn: (TimeSeriesData dataEntries, _) => dataEntries.data,
      data: dataEntries.map((dataEntry) {
        double data;
        if (dataEntry is NumberDataEntry) {
          data = dataEntry.data;
          prevData = data;
        } else
          data = prevData;

        return TimeSeriesData(data, dataEntry.time);
      }).toList(),
    )
  ];
}

class TimeSeriesData {
  final double data;
  final DateTime time;

  TimeSeriesData(this.data, this.time);
}
