import 'package:flutter/material.dart';
import 'package:iot_ui/data_model/DataEntry.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class PieChart extends StatelessWidget {
  final List<DataEntry> dataEntries;
  final String chartField;

  PieChart({@required this.dataEntries, @required this.chartField});

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(_getChartsData(dataEntries, chartField),
        animate: true,
        defaultRenderer: new charts.ArcRendererConfig(arcRendererDecorators: [
          new charts.ArcLabelDecorator(
              labelPosition: charts.ArcLabelPosition.outside)
        ]));
  }
}

List<charts.Series<MessagesPerField, String>> _getChartsData(
    List<DataEntry> dataEntries, String chartField) {
  Map<String, int> chartMap = Map<String, int>();
  switch (chartField) {
    case "Data type":
      {
        dataEntries.forEach((dataEntry) {
          if (chartMap.containsKey(dataEntry.type.toString()))
            chartMap.update(dataEntry.type.toString(), (prev) => prev + 1);
          else
            chartMap.putIfAbsent(dataEntry.type.toString(), () => 1);
        });
      }
      break;
    case "System name":
      {
        dataEntries.forEach((dataEntry) {
          if (chartMap.containsKey(dataEntry.systemName))
            chartMap.update(dataEntry.systemName, (prev) => prev + 1);
          else
            chartMap.putIfAbsent(dataEntry.systemName, () => 1);
        });
      }
      break;
    case "Device type":
      {
        dataEntries.forEach((dataEntry) {
          if (chartMap.containsKey(dataEntry.deviceType))
            chartMap.update(dataEntry.deviceType, (prev) => prev + 1);
          else
            chartMap.putIfAbsent(dataEntry.deviceType, () => 1);
        });
      }
      break;
    case "Device Id":
      {
        dataEntries.forEach((dataEntry) {
          if (chartMap.containsKey(dataEntry.deviceId))
            chartMap.update(dataEntry.deviceId, (prev) => prev + 1);
          else
            chartMap.putIfAbsent(dataEntry.deviceId, () => 1);
        });
      }
      break;
    case "Field name":
      {
        dataEntries.forEach((dataEntry) {
          if (chartMap.containsKey(dataEntry.fieldName))
            chartMap.update(dataEntry.fieldName, (prev) => prev + 1);
          else
            chartMap.putIfAbsent(dataEntry.fieldName, () => 1);
        });
      }
      break;
  }

  List<MessagesPerField> chartData = List<MessagesPerField>();
  chartMap.keys.forEach((key) {
    chartData.add(MessagesPerField(key, chartMap[key]));
  });

  print("charts: $chartMap\n");
  return [
    new charts.Series<MessagesPerField, String>(
      id: 'pieChart',
      domainFn: (MessagesPerField dataEntries, _) => dataEntries.chartField,
      measureFn: (MessagesPerField dataEntries, _) => dataEntries.count,
      data: chartData,
      labelAccessorFn: (MessagesPerField row, _) =>
          '${row.chartField}: ${row.count}',
    )
  ];
}

class MessagesPerField {
  final String chartField;
  final int count;

  MessagesPerField(this.chartField, this.count);
}
