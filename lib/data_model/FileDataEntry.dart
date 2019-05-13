import 'package:iot_ui/data_model/DataEntry.dart';
import 'package:iot_ui/services/DAL.dart';

class FileDataEntry extends DataEntry {
  String fileName;
  Future<dynamic> url;

  FileDataEntry(String deviceId, String deviceType, String system,
      DateTime time, String type, String fieldName, this.fileName)
      : super(deviceId, deviceType, system, time, type, fieldName) {
    url = DAL.getFileUrlFromStorage(fileName);
  }
}
