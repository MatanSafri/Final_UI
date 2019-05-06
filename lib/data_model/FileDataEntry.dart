import 'dart:io';
import 'package:iot_ui/data_model/DataEntry.dart';
import 'package:iot_ui/data_model/System.dart';

class FileDataEntry extends DataEntry {
  File data;
  Uri uri;

  FileDataEntry(String deviceId, String deviceType, String system,
      DateTime time, String type, String fieldName, this.uri,
      {bool downloadFile = true})
      : super(deviceId, deviceType, system, time, type, fieldName) {
    if (downloadFile) {}
  }
}
