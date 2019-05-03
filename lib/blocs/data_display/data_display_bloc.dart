import 'dart:async';
import 'dart:collection';

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
    _systemNames.addStream(DAL.getSystemCollection().transform(
        StreamTransformer<QuerySnapshot, List<String>>.fromHandlers(
            handleData: (data, sink) {
      sink.add(DAL.getSystemNamesFromQuery(data));
    })));
  }

  @override
  void dispose() async {
    await _currDataStreamSubscription?.cancel();
    await _systemNames?.close();
    await _systemsData?.close();
  }

  //final BehaviorSubject<List<String>>  _systemNames = BehaviorSubject<List<String>>();
  final BehaviorSubject<List<String>> _systemNames =
      BehaviorSubject<List<String>>();
  Stream<List<String>> get systemNamesStream => _systemNames.stream;

  PublishSubject<List<Map<String, dynamic>>> _systemsData =
      PublishSubject<List<Map<String, dynamic>>>();
  Stream<List<Map<String, dynamic>>> get systemsDataStream =>
      _systemsData.stream;

  StreamSubscription _currDataStreamSubscription;
  Map<String, Stream<List<Map<String, dynamic>>>> _dataStreams =
      HashMap<String, Stream<List<Map<String, dynamic>>>>();
  @override
  Stream<DataDisplayState> eventHandler(
      DataDisplayEvent event, DataDisplayState currentState) async* {
    if (event is InitDataDisplay) {
    } else if (event is ChangeSystemsSelection) {
      // clean up from prevStream query
      await _currDataStreamSubscription?.cancel();
      await _systemsData?.close();

      if (lastState != null)
        lastState.systemNames.forEach((prevSystem) {
          if (!event.newSystems.contains(prevSystem))
            _dataStreams.remove(prevSystem);
        });

      _systemsData = PublishSubject<List<Map<String, dynamic>>>();

      // transform the stream
      StreamTransformer trans = StreamTransformer<QuerySnapshot,
          List<Map<String, dynamic>>>.fromHandlers(handleData: handleData);
      event.newSystems.forEach((systemName) {
        _dataStreams.putIfAbsent(systemName,
            () => DAL.getDataCollection(systemName).transform(trans));
      });

      // need scan beacuse when stream merged  streambuilder widget build only at the second stream
      var combinedStream = Observable.merge(_dataStreams.values)
          .scan<List<Map<String, dynamic>>>((acc, curr, i) {
        return acc ?? <Map<String, dynamic>>[]
          ..addAll(curr);
      });

      _currDataStreamSubscription = combinedStream.listen((onData) {
        _systemsData.sink.add(onData);
      });

      yield DataDisplayState.systemsSelected(event.newSystems);
    }
  }

  void handleData(data, EventSink sink) {
    // var items = List<Map<String, dynamic>>();
    // data.documents.forEach((doc) {
    //   items.add(doc.data);
    // });
    // sink.add(items);

    sink.add(DAL.getSystemDataFromQuery(data));
  }
}
