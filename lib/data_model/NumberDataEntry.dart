import 'package:iot_ui/data_model/DataEntry.dart';
import 'package:iot_ui/data_model/System.dart';

class NumberDataEntry extends DataEntry {
  double data;

  NumberDataEntry(String deviceId, String deviceType, String system,
      DateTime time, String type, String fieldName, this.data)
      : super(deviceId, deviceType, system, time, type, fieldName);
}
