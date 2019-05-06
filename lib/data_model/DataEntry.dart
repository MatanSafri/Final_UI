import 'package:iot_ui/data_model/System.dart';

class DataEntry {
  String systemName;
  String deviceId;
  String deviceType;
  String type;
  DateTime time;
  String fieldName;
  DataEntry(this.deviceId, this.deviceType, this.systemName, this.time,
      this.type, this.fieldName);
}
