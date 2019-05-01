import 'package:cloud_firestore/cloud_firestore.dart';

class DAL {
  static Stream<QuerySnapshot> getSystemCollection() {
    return Firestore.instance.collection('systems').snapshots();
  }

  static List<String> getSystemNamesFromQuery(QuerySnapshot collection) {
    List<String> systemsNames = new List<String>();
    collection.documents.forEach((d) {
      systemsNames.add(d.data["name"]);
    });
    return systemsNames;
  }

  static void onSystemNameDataArrived(Function(String) func) {
    Firestore.instance.collection('systems').snapshots().listen((onData) {
      onData.documents.forEach((d) {
        func(d.data["name"]);
      });
    });
  }

  static Stream<QuerySnapshot> getDataCollection(String systemName) {
    return Firestore.instance
        .collection('systems')
        .document(systemName)
        .collection('data')
        .snapshots();
  }

  static List<Map<String, dynamic>> getSystemDataFromQuery(
      QuerySnapshot collection) {
    List<Map<String, dynamic>> systemsData = List<Map<String, dynamic>>();
    collection.documents.forEach((d) {
      systemsData.add(d.data);
    });
    return systemsData;
  }

  // static String getSystemName(QuerySnapshot snapshot)
  // {
  //     snapshot.documents.forEach((document){
  //       document.data["name"]
  //     });
  // }

  static Stream<String> getSystemsNames() async* {
    // final FirebaseApp app = await FirebaseApp.configure(
    //     name: 'test',
    //     options: const FirebaseOptions(
    //       clientID: '112209291642929601982',
    //       googleAppID: '1:714518887619:android:7116bafde85505d0',
    //       gcmSenderID: '714518887619',
    //       apiKey: 'AIzaSyArJrAgH3HB5YybLFbsQ3zKAI5T-twn9BE',
    //       projectID: 'iot-final-8b2e0',
    //     ));
    // final Firestore firestore = Firestore(app: app);

    //return Firestore.instance.collection('systems').document('weather').get();

    var collection = Firestore.instance.collection('systems');

    await for (var doc in collection.snapshots()) {
      for (var d in doc.documents) {
        print("${d.data["name"]}\n");
        yield d.data["name"];
      }
    }

    // Firestore.instance
    //     .collection('systems')
    //     .document('weather')
    //     .setData({'title': 'title', 'author': 'author'});
  }

  static Stream<Map<String, dynamic>> getSystemData(String systemName) async* {
    var collection = Firestore.instance
        .collection('systems')
        .document(systemName)
        .collection('data');
    await for (var doc in collection.snapshots()) {
      for (var d in doc.documents) {
        print("${d.data}\n");
        yield d.data;
      }
    }
  }
}
