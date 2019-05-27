import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iot_ui/blocs/bloc_helpers/bloc_provider.dart';
import 'package:iot_ui/data_model/DataEntry.dart';
import 'package:iot_ui/data_model/System.dart';
import 'package:iot_ui/services/DAL.dart';
import 'package:rxdart/rxdart.dart';

class DataDisplayBloc extends BlocBase {
  DataDisplayBloc() {
    _dataTypes.add(DataEntryType.values
        .map((type) => type.toString().split(".").last)
        .toList());

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
      _systemsDevices.sink
          .add(_allSystems.map((sys) => sys.devices).expand((i) => i).toList());

      _systemsDevicesTpyes.sink.add(
          _allSystems.map((sys) => sys.deviceTypes).expand((i) => i).toList());

      _systemsFieldsNames.add(
          _allSystems.map((sys) => sys.fieldNames).expand((i) => i).toList());
    });

    _systems.addStream(systemsStream);

    var systemsNamesStream = _systems.transform(
        StreamTransformer<List<System>, List<String>>.fromHandlers(
            handleData: (data, sink) {
      var systemNames = data.map((sys) => sys.systemName).toList();
      sink.add(systemNames);
    }));

    _systemsNames.addStream(systemsNamesStream);
  }
  List<System> _allSystems = List<System>();

  @override
  void dispose() async {
    for (var bs in _checkStateDataTypes.values) await bs?.close();
    await _currDataStreamSubscription?.cancel();
    await _systems?.close();
    await _systemsNames?.close();
    await _systemsDevices?.close();
    await _systemsDevicesTpyes?.close();
    await _systemsFieldsNames?.close();
    await _systemsData?.close();
    await _dataTypes?.close();
  }

  final Map<String, BehaviorSubject<bool>> _checkStateDataTypes =
      Map<String, BehaviorSubject<bool>>();
  Map<String, Stream<bool>> get checkStateDataTypesStream =>
      _checkStateDataTypes.map<String, Stream<bool>>(
          (key, value) => MapEntry(key, value.stream));

  final BehaviorSubject<List<System>> _systems =
      BehaviorSubject<List<System>>();
  Stream<List<System>> get systemStream => _systems.stream;

  final BehaviorSubject<List<String>> _dataTypes =
      BehaviorSubject<List<String>>();
  Stream<List<String>> get dataTypesStream => _dataTypes.stream;

  final BehaviorSubject<List<String>> _systemsNames =
      BehaviorSubject<List<String>>();
  Stream<List<String>> get systemNamesStream => _systemsNames.stream;

  final BehaviorSubject<List<String>> _systemsDevices =
      BehaviorSubject<List<String>>();
  Stream<List<String>> get systemDevicesStream => _systemsDevices.stream;

  final BehaviorSubject<List<String>> _systemsDevicesTpyes =
      BehaviorSubject<List<String>>();
  Stream<List<String>> get systemDevicesTypesStream =>
      _systemsDevicesTpyes.stream;

  final BehaviorSubject<List<String>> _systemsFieldsNames =
      BehaviorSubject<List<String>>();
  Stream<List<String>> get systemFieldsNamesStream =>
      _systemsFieldsNames.stream;

  PublishSubject<List<DataEntry>> _systemsData =
      PublishSubject<List<DataEntry>>();
  Stream<List<DataEntry>> get systemsDataStream => _systemsData.stream;

  StreamSubscription _currDataStreamSubscription;
  Map<String, Stream<List<DataEntry>>> _dataStreams =
      HashMap<String, Stream<List<DataEntry>>>();

  List<String> _selectedSystemsNames = <String>[];
  List<String> _selectedDevices = <String>[];
  List<String> _selectedFieldsNames = <String>[];
  List<String> _selectedDataTypes = <String>[];
  List<String> _selectedDeviceTypes = <String>[];
  DateTime _selectedStartDateTime;
  DateTime _selectedEndDateTime;

  void onDevicesSelectionChanged(List<String> selected) {
    _selectedDevices = selected;
  }

  void onDeviceTypesSelectionChanged(List<String> selected) {
    _selectedDeviceTypes = selected;
  }

  void onFieldNamesSelectionChanged(List<String> selected) {
    _selectedFieldsNames = selected;
  }

  void onDataTypesSelectionChanged(List<String> selected) {
    _selectedDataTypes = selected;
  }

  void onStartDateTimeChange(DateTime selected) {
    _selectedStartDateTime = selected;
  }

  void onEndDateTimeChange(DateTime selected) {
    _selectedEndDateTime = selected;
  }

  void onSystemSelectionChanged(List<String> selected) {
    _selectedSystemsNames = selected;
    print("onSystemSelectionChanged $selected\n");

    List<System> systems = selected.length == 0
        ? _allSystems
        : _allSystems
            .where((sys) => selected.contains(sys.systemName))
            .toList();

    _systemsDevices.sink
        .add(systems.map((sys) => sys.devices).expand((i) => i).toList());

    _systemsDevicesTpyes.sink
        .add(systems.map((sys) => sys.deviceTypes).expand((i) => i).toList());

    _systemsFieldsNames
        .add(systems.map((sys) => sys.fieldNames).expand((i) => i).toList());
  }

  void getData() async {
    // clean up from prevStream query
    await _currDataStreamSubscription?.cancel();
    //await _systemsData?.close();

    // TODO: add optimazition
    _dataStreams.clear();

    //_systemsData = PublishSubject<List<DataEntry>>();

    // transform the stream
    StreamTransformer trans =
        StreamTransformer<QuerySnapshot, List<DataEntry>>.fromHandlers(
            handleData: handleData);

    var querySystems = _selectedSystemsNames.length > 0
        ? _selectedSystemsNames
        : _allSystems.map((sys) => sys.systemName).toList();

    querySystems.forEach((systemName) {
      _dataStreams.putIfAbsent(
          systemName,
          () => DAL
              .getDataCollection(systemName,
                  deviceIds: _selectedDevices,
                  deviceTypes: _selectedDeviceTypes,
                  fieldsNames: _selectedFieldsNames,
                  dataTypes: _selectedDataTypes,
                  startDate: _selectedStartDateTime,
                  endDate: _selectedEndDateTime)
              .transform(trans));
    });

    // need scan beacuse when stream merged  streambuilder widget build only at the second stream
    var combinedStream = Observable.merge(_dataStreams.values)
        .scan<List<DataEntry>>((acc, curr, i) {
      // remove all the prev data entry from the acc
      acc?.removeWhere((prevDataEntry) {
        prevDataEntry.systemName == curr.first.systemName;
      });

      return acc ?? <DataEntry>[]
        ..addAll(curr);
    });

    _currDataStreamSubscription = combinedStream.listen((onData) {
      _systemsData.sink.add(onData);
    });
  }

  void handleData(data, EventSink sink) {
    sink.add(DAL.getSystemDataFromQuery(data));
  }
}
