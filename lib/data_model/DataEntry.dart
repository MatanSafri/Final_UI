import 'package:iot_ui/data_model/System.dart';
import 'package:tuple/tuple.dart';

class DataEntry {
  String systemName;
  String deviceId;
  String deviceType;
  String type;
  DateTime time;
  String fieldName;
  Tuple2<double, double> location;

  DataEntry(this.deviceId, this.deviceType, this.systemName, this.time,
      this.type, this.fieldName, this.location);
}
