import 'package:iot_ui/data_model/System.dart';
import 'package:tuple/tuple.dart';

enum DataEntryType {
  text,
  number,
  error,
  video,
  audio,
  image,
}

class DataEntry {
  String systemName;
  String deviceId;
  String deviceType;
  DataEntryType type;
  DateTime time;
  String fieldName;
  Tuple2<double, double> location;

  DataEntry(this.deviceId, this.deviceType, this.systemName, this.time,
      this.type, this.fieldName, this.location);

  static DataEntryType getDataEntryType(String str) {
    return DataEntryType.values.firstWhere(
        (e) => e.toString() == 'DataEntryType.' + str.toLowerCase());
  }
}
