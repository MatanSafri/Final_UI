import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iot_ui/data_model/DataEntry.dart';
import 'package:iot_ui/data_model/NumberDataEntry.dart';
import 'package:iot_ui/data_model/System.dart';
import 'package:iot_ui/data_model/TextDataEntry.dart';

class DAL {
  static Stream<QuerySnapshot> getSystemCollection() {
    return Firestore.instance.collection('systems').snapshots();
  }

  static List<System> getSystemsFromQuery(QuerySnapshot collection) {
    List<System> systems = new List<System>();
    collection.documents.forEach((d) {
      systems.add(System(
          d.data["name"],
          d.data["devices"].cast<String>(),
          d.data["device_types"].cast<String>(),
          d.data["field_names"].cast<String>()));
    });
    return systems;
  }

  static Stream<QuerySnapshot> getDataCollection(String systemName,
      {DateTime startDate,
      DateTime endDate,
      List<String> deviceIds,
      List<String> deviceTypes,
      List<String> fieldsNames,
      String type}) {
    var collection = Firestore.instance
        .collection('systems')
        .document(systemName)
        .collection('data');

    dynamic quary = collection;

    if (startDate != null)
      quary = quary.where("time", isGreaterThanOrEqualTo: startDate);

    if (endDate != null)
      quary = quary.where("time", isLessThanOrEqualTo: endDate);

    if (deviceIds != null) {
      deviceIds.forEach((device) {
        quary = quary.where("device_id", isEqualTo: device);
      });
    }

    if (deviceTypes != null)
      quary = quary.where("device_type", isEqualTo: deviceTypes);

    if (type != null) quary = quary.where("type", isEqualTo: type);

    return quary.snapshots();
  }

  static List<DataEntry> getSystemDataFromQuery(QuerySnapshot collection) {
    var systemsData = List<DataEntry>();
    collection.documents.forEach((d) {
      switch (d.data["type"].toString().toLowerCase()) {
        case "text":
          {
            systemsData.add(TextDataEntry(
                d.data["device_id"],
                d.data["device_type"],
                d.data["system_name"],
                DateTime.tryParse(d.data["time"]),
                d.data["type"],
                d.data["field_name"],
                d.data["data"]));
            break;
          }
        case "number":
          {
            systemsData.add(NumberDataEntry(
                d.data["device_id"],
                d.data["device_type"],
                d.data["system_name"],
                DateTime.tryParse(d.data["time"]),
                d.data["type"],
                d.data["field_name"],
                double.parse(d.data["data"])));
            break;
          }
      }
    });
    return systemsData;
  }
}
