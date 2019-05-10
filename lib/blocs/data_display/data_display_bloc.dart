import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iot_ui/blocs/bloc_helpers/bloc_event_state.dart';
import 'package:iot_ui/blocs/data_display/data_display_event.dart';
import 'package:iot_ui/blocs/data_display/data_display_state.dart';
import 'package:iot_ui/data_model/DataEntry.dart';
import 'package:iot_ui/data_model/System.dart';
import 'package:iot_ui/services/DAL.dart';
import 'package:rxdart/rxdart.dart';

class DataDisplayBloc
    extends BlocEventStateBase<DataDisplayEvent, DataDisplayState> {
  DataDisplayBloc()
      //: super(initialState: DataDisplayState.loadingData(List<String>())) {
      : super(initialState: DataDisplayState.init()) {
    //emitEvent(InitDataDisplay());
  }

  List<System> _allSystems = List<System>();

  @override
  void dispose() async {
    for (var bs in _checkStateSystemNames.values) await bs?.close();
    for (var bs in _checkStateDevices.values) await bs?.close();
    await _currDataStreamSubscription?.cancel();
    await _systems?.close();
    await _systemsNames?.close();
    await _systemsData?.close();
    await _endTimeDate?.close();
    await _startTimeDate?.close();
  }

  final BehaviorSubject<List<System>> _systems =
      BehaviorSubject<List<System>>();
  Stream<List<System>> get systemStream => _systems.stream;

  final BehaviorSubject<List<String>> _systemsNames =
      BehaviorSubject<List<String>>();
  Stream<List<String>> get systemNamesStream => _systemsNames.stream;

  // check state systems streams
  final Map<String, BehaviorSubject<bool>> _checkStateSystemNames =
      Map<String, BehaviorSubject<bool>>();
  Map<String, Stream<bool>> get checkStateSystemNamesStream =>
      _checkStateSystemNames.map<String, Stream<bool>>(
          (key, value) => MapEntry(key, value.stream));

  Map<String, StreamSink<bool>> get checkStateSystemNamesSink =>
      _checkStateSystemNames.map<String, StreamSink<bool>>(
          (key, value) => MapEntry(key, value.sink));

  final BehaviorSubject<List<String>> _systemsDevices =
      BehaviorSubject<List<String>>();
  Stream<List<String>> get systemDevicesStream => _systemsDevices.stream;

  // check state systems streams
  final Map<String, BehaviorSubject<bool>> _checkStateDevices =
      Map<String, BehaviorSubject<bool>>();
  Map<String, Stream<bool>> get checkStateDevicesStream => _checkStateDevices
      .map<String, Stream<bool>>((key, value) => MapEntry(key, value.stream));

  Map<String, StreamSink<bool>> get checkStateDevicesSink => _checkStateDevices
      .map<String, StreamSink<bool>>((key, value) => MapEntry(key, value.sink));

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

  List<String> _checkedSystemsDevices = List<String>();

  @override
  Stream<DataDisplayState> eventHandler(
      DataDisplayEvent event, DataDisplayState currentState) async* {
    if (event is InitDataDisplay) {
      // TODO: add a listener and close it
      var systemsStream = DAL.getSystemCollection().transform(
          StreamTransformer<QuerySnapshot, List<System>>.fromHandlers(
              handleData: (data, sink) {
        var systems = DAL.getSystemsFromQuery(data);
        _allSystems.clear();
        _allSystems.addAll(systems);
        sink.add(systems);
      }));

      // listen to systems stream to update devices
      systemsStream.listen((data) {
        // TOOD: work on document changes not all documents
        // getting all the checked systems devices and adding all new devices
        // check if there is selected systems

        if (lastState == null ||
            lastState == initialState ||
            lastState.systemNames.length == 0) {
          _systemsDevices.sink.add(
              _allSystems.map((sys) => sys.devices).expand((i) => i).toList());
        } else {
          _allSystems
              .where((sys) => lastState.systemNames.contains(sys.systemName))
              .forEach((selectedSys) {
            selectedSys.devices.forEach((selectedSystemsDevice) {
              if (!_checkedSystemsDevices.contains(selectedSystemsDevice))
                _checkedSystemsDevices.add(selectedSystemsDevice);
            });
          });
          _systemsDevices.sink.add(_checkedSystemsDevices.toList());
        }
      });

      _systems.addStream(systemsStream);

      var systemsNamesStream = _systems.transform(
          StreamTransformer<List<System>, List<String>>.fromHandlers(
              handleData: (data, sink) {
        var systemNames = data.map((sys) => sys.systemName).toList();
        sink.add(systemNames);
      }));

      // TODO: save and close the listener
      _systemsDevices.listen((onData) {
        onData.forEach((device) {
          _checkStateDevices.putIfAbsent(device, () => BehaviorSubject<bool>());
        });
      });

      systemsNamesStream.listen((onData) {
        onData.forEach((systemName) {
          _checkedSystemsDevices.clear();
          var checkStream = BehaviorSubject<bool>();
          var currSystemDevices = _allSystems
              .firstWhere((sys) => sys.systemName == systemName)
              .devices;
          _checkStateSystemNames.putIfAbsent(systemName, () => checkStream);
          checkStream.listen((data) {
            if (data) {
              print("$currSystemDevices\n");
              _checkedSystemsDevices.addAll(currSystemDevices);
            } else {
              currSystemDevices.forEach((device) {
                _checkStateDevices[device]?.close();
                _checkStateDevices.remove(device);
                _checkedSystemsDevices.remove(device);
              });
            }
          });
        });
      });

      _systemsNames.addStream(systemsNamesStream);
    } else if (event is ChangeSystemSelection) {
      // check the current selection - systemNames didn't update yet
      if (currentState.systemNames.length == 1 && !event.selection)
        _systemsDevices.sink.add(
            _allSystems.map((sys) => sys.devices).expand((i) => i).toList());
      else
        _systemsDevices.sink.add(_checkedSystemsDevices);

      if (event.selection) {
        yield DataDisplayState(
            (currentState.systemNames + [event.systemName]).toList(),
            currentState.devices,
            currentState.deviceTypes,
            currentState.fieldNames,
            currentState.startDateTime,
            currentState.endDateTime);
      } else {
        var update = currentState.systemNames.toList();
        update.remove(event.systemName);
        yield DataDisplayState(
            update,
            currentState.devices,
            currentState.deviceTypes,
            currentState.fieldNames,
            currentState.startDateTime,
            currentState.endDateTime);
      }
    } else if (event is ChangeDevicesSelection) {
      if (event.selection) {
        yield DataDisplayState(
            currentState.systemNames,
            currentState.deviceTypes + [event.device],
            currentState.deviceTypes,
            currentState.fieldNames,
            currentState.startDateTime,
            currentState.endDateTime);
      } else {
        var update = currentState.devices.toList();
        update.remove(event.device);
        yield DataDisplayState(
            currentState.systemNames,
            update,
            currentState.deviceTypes,
            currentState.fieldNames,
            currentState.startDateTime,
            currentState.endDateTime);
      }
    } else if (event is ChangeStartTimeDate) {
      yield DataDisplayState(
          currentState.systemNames,
          currentState.devices,
          currentState.deviceTypes,
          currentState.fieldNames,
          event.startTimeDate,
          currentState.endDateTime);
    } else if (event is ChangeEndTimeDate) {
      yield DataDisplayState(
          currentState.systemNames,
          currentState.devices,
          currentState.deviceTypes,
          currentState.fieldNames,
          currentState.startDateTime,
          event.endTimeDate);
    } else if (event is ClearDatesSelection) {
      yield DataDisplayState(currentState.systemNames, currentState.devices,
          currentState.deviceTypes, currentState.fieldNames, null, null);
    } else if (event is ClearSystemsSelection) {
      yield DataDisplayState(
          List<String>(),
          currentState.devices,
          currentState.deviceTypes,
          currentState.fieldNames,
          currentState.startDateTime,
          currentState.endDateTime);
    } else if (event is ClearDevicesSelection) {
      yield DataDisplayState(
          currentState.systemNames,
          List<String>(),
          currentState.deviceTypes,
          currentState.fieldNames,
          currentState.startDateTime,
          currentState.endDateTime);
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
          : _allSystems.map((sys) => sys.systemName).toList();

      print("query Systems: $querySystems \n");
      querySystems.forEach((systemName) {
        _dataStreams.putIfAbsent(
            systemName,
            () => DAL
                .getDataCollection(systemName,
                    deviceIds: currentState.devices,
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

      yield DataDisplayState(
          currentState.systemNames,
          currentState.devices,
          currentState.deviceTypes,
          currentState.fieldNames,
          currentState.startDateTime,
          currentState.endDateTime);
    }
  }

  void handleData(data, EventSink sink) {
    sink.add(DAL.getSystemDataFromQuery(data));
  }
}
