import 'dart:async';

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iot_ui/blocs/bloc_helpers/bloc_event_state.dart';
import 'package:iot_ui/blocs/data_display/data_display_event.dart';
import 'package:iot_ui/blocs/data_display/data_display_state.dart';
import 'package:iot_ui/services/DAL.dart';
import 'package:rxdart/rxdart.dart';

class DataDisplayBloc
    extends BlocEventStateBase<DataDisplayEvent, DataDisplayState> {
  DataDisplayBloc()
      : super(initialState: DataDisplayState.loadingData(List<String>())) {
    // DAL.onSystemNameDataArrived((systemName) {
    //   emitEvent(SystemNameArrivedFromDb(newSystem: systemName));
    // });
    _systemNames.addStream(DAL.getSystemCollection());
  }

  @override
  void dispose() {
    _systemNames?.close();
    _systemsData?.close();
  }

  //final BehaviorSubject<List<String>>  _systemNames = BehaviorSubject<List<String>>();
  final BehaviorSubject<QuerySnapshot> _systemNames =
      BehaviorSubject<QuerySnapshot>();
  Stream<QuerySnapshot> get systemNamesStream => _systemNames.stream;

  BehaviorSubject<List<Map<String, dynamic>>> _systemsData =
      BehaviorSubject<List<Map<String, dynamic>>>();
  Stream<List<Map<String, dynamic>>> get systemsDataStream =>
      _systemsData.stream;

  @override
  Stream<DataDisplayState> eventHandler(
      DataDisplayEvent event, DataDisplayState currentState) async* {
    if (event is InitDataDisplay) {
    } else if (event is ChangeSystemsSelection) {
      _systemsData = BehaviorSubject<List<Map<String, dynamic>>>();

      var streams = List<Stream<List<Map<String, dynamic>>>>();

      // transform the stream
      StreamTransformer trans = new StreamTransformer<QuerySnapshot,
          List<Map<String, dynamic>>>.fromHandlers(handleData: handleData);
      event.newSystems.forEach((systemName) {
        streams.add(DAL.getDataCollection(systemName).transform(trans));
      });

      // need scan beacuse when stream merged  streambuilder widget build only at the second stream
      var combinedStream = Observable.merge(streams)
          .scan<List<Map<String, dynamic>>>((acc, curr, i) {
        return acc ?? <Map<String, dynamic>>[]
          ..addAll(curr);
      });

      combinedStream.listen((onData) {
        _systemsData.sink.add(onData);
      });

      //_systemsData.addStream(combinedStream);

      yield DataDisplayState.systemsSelected(currentState.systemNames);
    }
  }

  void handleData(data, EventSink sink) {
    var items = List<Map<String, dynamic>>();
    data.documents.forEach((doc) {
      items.add(doc.data);
    });
    sink.add(items);
  }
}
