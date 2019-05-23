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
  DataDisplayBloc() : super(initialState: DataDisplayState.init());
  List<System> _allSystems = List<System>();

  @override
  void dispose() async {
    for (var bs in _checkStateDevices.values) await bs?.close();
    for (var bs in _checkStateDevicesTypes.values) await bs?.close();
    for (var bs in _checkStateFieldsNames.values) await bs?.close();
    for (var bs in _checkStateSystemNames.values) await bs?.close();
    for (var bs in _checkStateDataTypes.values) await bs?.close();
    await _currDataStreamSubscription?.cancel();
    await _systems?.close();
    await _systemsNames?.close();
    await _systemsDevices?.close();
    await _systemsDevicesTpyes?.close();
    await _systemsFieldsNames?.close();
    await _systemsData?.close();
    await _endTimeDate?.close();
    await _startTimeDate?.close();
  }

  final Map<String, BehaviorSubject<bool>> _checkStateDataTypes =
      Map<String, BehaviorSubject<bool>>();
  Map<String, Stream<bool>> get checkStateDataTypesStream =>
      _checkStateDataTypes.map<String, Stream<bool>>(
          (key, value) => MapEntry(key, value.stream));

  Map<String, StreamSink<bool>> get checkStateDataTypesSink =>
      _checkStateDataTypes.map<String, StreamSink<bool>>(
          (key, value) => MapEntry(key, value.sink));

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

  final BehaviorSubject<List<String>> _systemsDevicesTpyes =
      BehaviorSubject<List<String>>();
  Stream<List<String>> get systemDevicesTypesStream =>
      _systemsDevicesTpyes.stream;

  // check state systems streams
  final Map<String, BehaviorSubject<bool>> _checkStateDevicesTypes =
      Map<String, BehaviorSubject<bool>>();
  Map<String, Stream<bool>> get checkStateDevicesTypesStream =>
      _checkStateDevicesTypes.map<String, Stream<bool>>(
          (key, value) => MapEntry(key, value.stream));

  Map<String, StreamSink<bool>> get checkStateDevicesTypesSink =>
      _checkStateDevicesTypes.map<String, StreamSink<bool>>(
          (key, value) => MapEntry(key, value.sink));

  final BehaviorSubject<List<String>> _systemsFieldsNames =
      BehaviorSubject<List<String>>();
  Stream<List<String>> get systemFieldsNamesStream =>
      _systemsFieldsNames.stream;

  // check state systems streams
  final Map<String, BehaviorSubject<bool>> _checkStateFieldsNames =
      Map<String, BehaviorSubject<bool>>();
  Map<String, Stream<bool>> get checkStateFieldsNamesStream =>
      _checkStateFieldsNames.map<String, Stream<bool>>(
          (key, value) => MapEntry(key, value.stream));

  Map<String, StreamSink<bool>> get checkStateFieldsNamesSink =>
      _checkStateFieldsNames.map<String, StreamSink<bool>>(
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

  List<String> _checkedSystemsDevices = List<String>();
  List<String> _checkedSystemsDevicesTypes = List<String>();
  List<String> _checkedSystemsFieldsNames = List<String>();

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

      DataEntryType.values.forEach((type) {
        _checkStateDataTypes.putIfAbsent(
            type.toString().split(".").last, () => BehaviorSubject<bool>());
      });

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

          _systemsDevicesTpyes.sink.add(_allSystems
              .map((sys) => sys.deviceTypes)
              .expand((i) => i)
              .toList());

          _systemsFieldsNames.add(_allSystems
              .map((sys) => sys.fieldNames)
              .expand((i) => i)
              .toList());
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

          _allSystems
              .where((sys) => lastState.systemNames.contains(sys.systemName))
              .forEach((selectedSys) {
            selectedSys.deviceTypes.forEach((selectedSystemsDeviceTypes) {
              if (!_checkedSystemsDevicesTypes
                  .contains(selectedSystemsDeviceTypes))
                _checkedSystemsDevicesTypes.add(selectedSystemsDeviceTypes);
            });
          });

          _systemsDevicesTpyes.sink.add(_checkedSystemsDevicesTypes.toList());

          _allSystems
              .where((sys) => lastState.systemNames.contains(sys.systemName))
              .forEach((selectedSys) {
            selectedSys.fieldNames.forEach((selectedSystemsFieldsNames) {
              if (!_checkedSystemsFieldsNames
                  .contains(selectedSystemsFieldsNames))
                _checkedSystemsFieldsNames.add(selectedSystemsFieldsNames);
            });
          });

          _systemsDevices.sink.add(_checkedSystemsFieldsNames.toList());
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

      // TODO: save and close the listener
      _systemsDevicesTpyes.listen((onData) {
        onData.forEach((device) {
          _checkStateDevicesTypes.putIfAbsent(
              device, () => BehaviorSubject<bool>());
        });
      });

      // TODO: save and close the listener
      _systemsFieldsNames.listen((onData) {
        onData.forEach((device) {
          _checkStateFieldsNames.putIfAbsent(
              device, () => BehaviorSubject<bool>());
        });
      });

      systemsNamesStream.listen((onData) {
        onData.forEach((systemName) {
          _checkedSystemsDevices.clear();
          _checkedSystemsDevicesTypes.clear();
          _checkedSystemsFieldsNames.clear();

          var checkStream = BehaviorSubject<bool>();
          var currSystemDevices = _allSystems
              .firstWhere((sys) => sys.systemName == systemName)
              .devices;
          var currSystemDevicesTypes = _allSystems
              .firstWhere((sys) => sys.systemName == systemName)
              .deviceTypes;
          var currSystemFieldsNames = _allSystems
              .firstWhere((sys) => sys.systemName == systemName)
              .fieldNames;
          _checkStateSystemNames.putIfAbsent(systemName, () => checkStream);
          checkStream.listen((data) {
            if (data) {
              print("$currSystemDevices\n");
              _checkedSystemsDevices.addAll(currSystemDevices);
              _checkedSystemsDevicesTypes.addAll(currSystemDevicesTypes);
              _checkedSystemsFieldsNames.addAll(currSystemFieldsNames);
            } else {
              currSystemDevices.forEach((device) {
                _checkStateDevices[device]?.close();
                _checkStateDevices.remove(device);
                _checkedSystemsDevices.remove(device);
              });

              currSystemDevicesTypes.forEach((devicesTypes) {
                _checkStateDevicesTypes[devicesTypes]?.close();
                _checkStateDevicesTypes.remove(devicesTypes);
                _checkedSystemsDevicesTypes.remove(devicesTypes);
              });

              currSystemFieldsNames.forEach((devicesTypes) {
                _checkStateFieldsNames[devicesTypes]?.close();
                _checkStateFieldsNames.remove(devicesTypes);
                _checkedSystemsFieldsNames.remove(devicesTypes);
              });
            }
          });
        });
      });

      _systemsNames.addStream(systemsNamesStream);
    } else if (event is ChangeSystemSelection) {
      // check the current selection - systemNames didn't update yet
      if (currentState.systemNames.length == 1 && !event.selection) {
        _systemsDevices.sink.add(
            _allSystems.map((sys) => sys.devices).expand((i) => i).toList());

        _systemsDevicesTpyes.sink.add(_allSystems
            .map((sys) => sys.deviceTypes)
            .expand((i) => i)
            .toList());

        _systemsFieldsNames.sink.add(
            _allSystems.map((sys) => sys.fieldNames).expand((i) => i).toList());
      } else {
        _systemsDevices.sink.add(_checkedSystemsDevices);
        _systemsDevicesTpyes.sink.add(_checkedSystemsDevicesTypes);
        _systemsFieldsNames.sink.add(_checkedSystemsFieldsNames);
      }

      if (event.selection) {
        yield DataDisplayState(
            (currentState.systemNames + [event.systemName]).toList(),
            currentState.devices,
            currentState.deviceTypes,
            currentState.fieldNames,
            currentState.dataTypes,
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
            currentState.dataTypes,
            currentState.startDateTime,
            currentState.endDateTime);
      }
    } else if (event is ChangeDevicesSelection) {
      if (event.selection) {
        yield DataDisplayState(
            currentState.systemNames,
            currentState.devices + [event.device],
            currentState.deviceTypes,
            currentState.fieldNames,
            currentState.dataTypes,
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
            currentState.dataTypes,
            currentState.startDateTime,
            currentState.endDateTime);
      }
    } else if (event is ChangeDevicesTypesSelection) {
      if (event.selection) {
        yield DataDisplayState(
            currentState.systemNames,
            currentState.devices,
            currentState.deviceTypes + [event.deviceType],
            currentState.fieldNames,
            currentState.dataTypes,
            currentState.startDateTime,
            currentState.endDateTime);
      } else {
        var update = currentState.deviceTypes.toList();
        update.remove(event.deviceType);
        yield DataDisplayState(
            currentState.systemNames,
            currentState.devices,
            update,
            currentState.fieldNames,
            currentState.dataTypes,
            currentState.startDateTime,
            currentState.endDateTime);
      }
    } else if (event is ChangeFieldsNamesSelection) {
      if (event.selection) {
        yield DataDisplayState(
            currentState.systemNames,
            currentState.devices,
            currentState.deviceTypes,
            currentState.fieldNames + [event.fieldName],
            currentState.dataTypes,
            currentState.startDateTime,
            currentState.endDateTime);
      } else {
        var update = currentState.fieldNames.toList();
        update.remove(event.fieldName);
        yield DataDisplayState(
            currentState.systemNames,
            currentState.devices,
            currentState.deviceTypes,
            update,
            currentState.dataTypes,
            currentState.startDateTime,
            currentState.endDateTime);
      }
    } else if (event is ChangeDataTypeSelection) {
      if (event.selection) {
        yield DataDisplayState(
            currentState.systemNames,
            currentState.devices,
            currentState.deviceTypes,
            currentState.fieldNames,
            currentState.dataTypes + [event.dataType],
            currentState.startDateTime,
            currentState.endDateTime);
      } else {
        var update = currentState.dataTypes.toList();
        update.remove(event.dataType);
        yield DataDisplayState(
            currentState.systemNames,
            currentState.devices,
            currentState.deviceTypes,
            currentState.fieldNames,
            update,
            currentState.startDateTime,
            currentState.endDateTime);
      }
    } else if (event is ChangeStartTimeDate) {
      yield DataDisplayState(
          currentState.systemNames,
          currentState.devices,
          currentState.deviceTypes,
          currentState.fieldNames,
          currentState.dataTypes,
          event.startTimeDate,
          currentState.endDateTime);
    } else if (event is ChangeEndTimeDate) {
      yield DataDisplayState(
          currentState.systemNames,
          currentState.devices,
          currentState.deviceTypes,
          currentState.fieldNames,
          currentState.dataTypes,
          currentState.startDateTime,
          event.endTimeDate);
    } else if (event is ClearDatesSelection) {
      yield DataDisplayState(
          currentState.systemNames,
          currentState.devices,
          currentState.deviceTypes,
          currentState.fieldNames,
          currentState.dataTypes,
          null,
          null);
    } else if (event is ClearSystemsSelection) {
      yield DataDisplayState(
          List<String>(),
          currentState.devices,
          currentState.deviceTypes,
          currentState.fieldNames,
          currentState.dataTypes,
          currentState.startDateTime,
          currentState.endDateTime);
    } else if (event is ClearDevicesSelection) {
      yield DataDisplayState(
          currentState.systemNames,
          List<String>(),
          currentState.deviceTypes,
          currentState.fieldNames,
          currentState.dataTypes,
          currentState.startDateTime,
          currentState.endDateTime);
    } else if (event is ClearDataTypesSelection) {
      yield DataDisplayState(
          currentState.systemNames,
          currentState.devices,
          currentState.deviceTypes,
          currentState.fieldNames,
          List<String>(),
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
                    deviceTypes: currentState.deviceTypes,
                    fieldsNames: currentState.fieldNames,
                    dataTypes: currentState.dataTypes,
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
          currentState.dataTypes,
          currentState.startDateTime,
          currentState.endDateTime);
    }
  }

  void handleData(data, EventSink sink) {
    sink.add(DAL.getSystemDataFromQuery(data));
  }
}
