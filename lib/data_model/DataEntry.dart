import 'package:cloud_firestore/cloud_firestore.dart';

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
  GeoPoint location;

  DataEntry(this.deviceId, this.deviceType, this.systemName, this.time,
      this.type, this.fieldName, this.location);

  static DataEntryType getDataEntryType(String str) {
    return DataEntryType.values.firstWhere(
        (e) => e.toString() == 'DataEntryType.' + str.toLowerCase());
  }
}
