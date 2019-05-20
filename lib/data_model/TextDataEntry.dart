import 'package:iot_ui/data_model/DataEntry.dart';
import 'package:iot_ui/data_model/System.dart';
import 'package:tuple/tuple.dart';

class TextDataEntry extends DataEntry {
  String data;

  TextDataEntry(
      String deviceId,
      String deviceType,
      String system,
      DateTime time,
      String type,
      String fieldName,
      Tuple2<double, double> location,
      this.data)
      : super(deviceId, deviceType, system, time, type, fieldName, location);
}
