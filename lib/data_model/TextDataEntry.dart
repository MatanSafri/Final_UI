import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iot_ui/data_model/DataEntry.dart';

class TextDataEntry extends DataEntry {
  String data;

  TextDataEntry(
      String deviceId,
      String deviceType,
      String system,
      DateTime time,
      DataEntryType type,
      String fieldName,
      GeoPoint location,
      this.data)
      : super(deviceId, deviceType, system, time, type, fieldName, location);
}
