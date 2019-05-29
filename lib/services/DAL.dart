import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iot_ui/data_model/DataEntry.dart';
import 'package:iot_ui/data_model/FileDataEntry.dart';
import 'package:iot_ui/data_model/NumberDataEntry.dart';
import 'package:iot_ui/data_model/System.dart';
import 'package:iot_ui/data_model/TextDataEntry.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DAL {
  static Stream<QuerySnapshot> getAllSystemsCollection() {
    return Firestore.instance.collection('systems').snapshots();
  }

  static Stream<DocumentSnapshot> getSystemsNamesOfUser(String userId) {
    return Firestore.instance.collection('users').document(userId).snapshots();
  }

  static List<String> getAllSystemsOfUserFromDocument(
      DocumentSnapshot document) {
    return document.data["systems"].cast<String>();
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

  static Future<dynamic> getFileUrlFromStorage(String fileName) {
    final StorageReference ref = FirebaseStorage.instance.ref().child(fileName);
    return ref.getDownloadURL();
  }

  static Stream<QuerySnapshot> getDataCollection(String systemName,
      {DateTime startDate,
      DateTime endDate,
      List<String> deviceIds,
      List<String> deviceTypes,
      List<String> fieldsNames,
      List<String> dataTypes}) {
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
      deviceTypes.forEach((deviceType) {
        quary = quary.where("device_type", isEqualTo: deviceType);
      });

    if (fieldsNames != null)
      fieldsNames.forEach((fieldName) {
        quary = quary.where("field_name", isEqualTo: fieldName);
      });

    if (dataTypes != null)
      dataTypes.forEach((dataType) {
        quary = quary.where("type", isEqualTo: dataType);
      });

    return quary.snapshots();
  }

  static List<DataEntry> getSystemDataFromQuery(QuerySnapshot collection) {
    var systemsData = List<DataEntry>();
    collection.documents.forEach((d) {
      GeoPoint location;

      if (d.data.containsKey("location")) {
        try {
          location = d.data["location"];
        } catch (e) {
          print("${e.toString()}\n");
        }
      }
      DateTime time = DateTime.fromMicrosecondsSinceEpoch(
          (d.data["time"] as Timestamp).microsecondsSinceEpoch);
      switch (d.data["type"].toString().toLowerCase()) {
        case "text":
          {
            systemsData.add(TextDataEntry(
                d.data["device_id"],
                d.data["device_type"],
                d.data["system_name"],
                time,
                DataEntry.getDataEntryType(d.data["type"]),
                d.data["field_name"],
                location,
                d.data["data"]));
            break;
          }
        case "number":
          {
            systemsData.add(NumberDataEntry(
                d.data["device_id"],
                d.data["device_type"],
                d.data["system_name"],
                time,
                DataEntry.getDataEntryType(d.data["type"]),
                d.data["field_name"],
                location,
                d.data["data"].toDouble()));
            break;
          }
        case "image":
        case "audio":
        case "video":
          systemsData.add(FileDataEntry(
              d.data["device_id"],
              d.data["device_type"],
              d.data["system_name"],
              time,
              DataEntry.getDataEntryType(d.data["type"]),
              d.data["field_name"],
              location,
              d.data["data"]));
      }
    });
    return systemsData;
  }

  static Future<void> updateUserSystems(
      String userId, List<String> systemsOfUser) {
    print("user id $userId systems: $systemsOfUser \n");
    return Firestore.instance
        .collection('users')
        .document(userId)
        .setData({'systems': systemsOfUser});
  }
}
