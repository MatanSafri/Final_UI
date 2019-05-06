import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iot_ui/blocs/bloc_helpers/bloc_event_state.dart';
import 'package:iot_ui/blocs/data_display/data_display_event.dart';
import 'package:iot_ui/blocs/data_display/data_display_state.dart';
import 'package:iot_ui/data_model/DataEntry.dart';
import 'package:iot_ui/services/DAL.dart';
import 'package:rxdart/rxdart.dart';

class DataDisplayBloc
    extends BlocEventStateBase<DataDisplayEvent, DataDisplayState> {
  DataDisplayBloc()
      //: super(initialState: DataDisplayState.loadingData(List<String>())) {
      : super(initialState: DataDisplayState.init()) {
    // TODO: add a listener and close it
    var systemsNamesStream = DAL.getSystemCollection().transform(
        StreamTransformer<QuerySnapshot, List<String>>.fromHandlers(
            handleData: (data, sink) {
      var systemNames = DAL.getSystemNamesFromQuery(data);
      sink.add(systemNames);
      _allSystemsNames.clear();
      _allSystemsNames.addAll(systemNames);
    }));

    // TODO: save and close the listener
    systemsNamesStream.listen((onData) {
      onData.forEach((systemName) {
        _checkStateSystemNames.putIfAbsent(
            systemName, () => BehaviorSubject<bool>());
      });
    });

    _systemNames.addStream(systemsNamesStream);
  }

  List<String> _allSystemsNames = List<String>();

  @override
  void dispose() async {
    for (var bs in _checkStateSystemNames.values) await bs?.close();
    await _currDataStreamSubscription?.cancel();
    await _systemNames?.close();
    await _systemsData?.close();
    await _endTimeDate?.close();
    await _startTimeDate?.close();
  }

  //final BehaviorSubject<List<String>>  _systemNames = BehaviorSubject<List<String>>();
  final BehaviorSubject<List<String>> _systemNames =
      BehaviorSubject<List<String>>();
  Stream<List<String>> get systemNamesStream => _systemNames.stream;

  // check state systems streams
  final Map<String, BehaviorSubject<bool>> _checkStateSystemNames =
      Map<String, BehaviorSubject<bool>>();
  Map<String, Stream<bool>> get checkStateSystemNamesStream =>
      _checkStateSystemNames.map<String, Stream<bool>>(
          (key, value) => MapEntry(key, value.stream));

  Map<String, StreamSink<bool>> get checkStateSystemNamesSink =>
      _checkStateSystemNames.map<String, StreamSink<bool>>(
          (key, value) => MapEntry(key, value.sink));

  PublishSubject<List<DataEntry>> _systemsData =
      PublishSubject<List<DataEntry>>();
  Stream<List<DataEntry>> get systemsDataStream => _systemsData.stream;

  StreamSubscription _currDataStreamSubscription;
  Map<String, Stream<List<DataEntry>>> _dataStreams =
      HashMap<String, Stream<List<DataEntry>>>();

  final BehaviorSubject<DateTime> _endTimeDate = BehaviorSubject<DateTime>();
  Stream<DateTime> get endTimeDateStream => _endTimeDate.stream;
  StreamSink<DateTime> get endTimeDateSink => _endTimeDate.sink;

  final BehaviorSubject<DateTime> _startTimeDate = BehaviorSubject<DateTime>();
  Stream<DateTime> get startTimeDateStream => _startTimeDate.stream;
  StreamSink<DateTime> get startTimeDateSink => _startTimeDate.sink;

  @override
  Stream<DataDisplayState> eventHandler(
      DataDisplayEvent event, DataDisplayState currentState) async* {
    if (event is InitDataDisplay) {
    } else if (event is ChangeSystemSelection) {
      if (event.selection) {
        yield DataDisplayState(
            (currentState.systemNames + [event.systemName]).toList(),
            currentState.startDateTime,
            currentState.endDateTime);
      } else {
        var x = currentState.systemNames.toList();
        x.remove(event.systemName);
        yield DataDisplayState(
            x, currentState.startDateTime, currentState.endDateTime);
      }
    } else if (event is ChangeStartTimeDate) {
      yield DataDisplayState(currentState.systemNames, event.startTimeDate,
          currentState.endDateTime);
    } else if (event is ChangeEndTimeDate) {
      yield DataDisplayState(currentState.systemNames,
          currentState.startDateTime, event.endTimeDate);
    } else if (event is ClearDatesSelection) {
      yield DataDisplayState(currentState.systemNames, null, null);
    } else if (event is ClearSystemsSelection) {
      yield DataDisplayState(
          List<String>(), currentState.startDateTime, currentState.endDateTime);
    } else if (event is DisplayData) {
      // clean up from prevStream query
      await _currDataStreamSubscription?.cancel();
      await _systemsData?.close();

      print("${currentState.systemNames}\n");

      // TODO: add optimazition
      _dataStreams.clear();
      //if (lastState != null) {

      //lastState.systemNames.forEach((prevSystem) {
      //   if (!currentState.systemNames.contains(prevSystem))
      //     _dataStreams.remove(prevSystem);
      // });
      // }

      _systemsData = PublishSubject<List<DataEntry>>();

      // transform the stream
      StreamTransformer trans =
          StreamTransformer<QuerySnapshot, List<DataEntry>>.fromHandlers(
              handleData: handleData);
      var querySystems = currentState.systemNames.length > 0
          ? currentState.systemNames
          : _allSystemsNames;
      print("query Systems: $querySystems \n");
      querySystems.forEach((systemName) {
        _dataStreams.putIfAbsent(
            systemName,
            () => DAL
                .getDataCollection(systemName,
                    startDate: currentState.startDateTime,
                    endDate: currentState.endDateTime)
                .transform(trans));
      });

      print("${_dataStreams.length}\n");

      // need scan beacuse when stream merged  streambuilder widget build only at the second stream
      var combinedStream = Observable.merge(_dataStreams.values)
          .scan<List<DataEntry>>((acc, curr, i) {
        return acc ?? <DataEntry>[]
          ..addAll(curr);
      });

      _currDataStreamSubscription = combinedStream.listen((onData) {
        _systemsData.sink.add(onData);
      });

      yield DataDisplayState(currentState.systemNames,
          currentState.startDateTime, currentState.endDateTime);
    }
  }

  void handleData(data, EventSink sink) {
    sink.add(DAL.getSystemDataFromQuery(data));
  }
}
