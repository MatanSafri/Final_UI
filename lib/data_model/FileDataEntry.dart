import 'package:iot_ui/data_model/DataEntry.dart';
import 'package:iot_ui/services/DAL.dart';
import 'package:tuple/tuple.dart';

class FileDataEntry extends DataEntry {
  String fileName;
  Future<dynamic> url;

  FileDataEntry(
      String deviceId,
      String deviceType,
      String system,
      DateTime time,
      DataEntryType type,
      String fieldName,
      Tuple2<double, double> location,
      this.fileName)
      : super(deviceId, deviceType, system, time, type, fieldName, location) {
    url = DAL.getFileUrlFromStorage(fileName);
  }
}
