import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iot_ui/blocs/bloc_helpers/bloc_provider.dart';
import 'package:iot_ui/data_model/DataEntry.dart';
import 'package:iot_ui/data_model/System.dart';
import 'package:iot_ui/services/DAL.dart';
import 'package:rxdart/rxdart.dart';

class DataDisplayBloc extends BlocBase {
  var _userId;

  DataDisplayBloc(String userId) {
    _userId = userId;
    _dataTypes.add(DataEntryType.values
        .map((type) => type.toString().split(".").last)
        .toList());

    // TODO: add a listener and close it
    var allSystemsStream = DAL.getAllSystemsCollection().transform(
        StreamTransformer<QuerySnapshot, List<System>>.fromHandlers(
            handleData: (data, sink) {
      var systems = DAL.getSystemsFromQuery(data);
      sink.add(systems);
    }));

    var allSystemNamesStream = allSystemsStream.transform(
        StreamTransformer<List<System>, List<String>>.fromHandlers(
            handleData: (data, sink) {
      sink.add(data.map((system) => system.systemName).toList());
    }));

    var userSystemsNamesStream = DAL.getSystemsNamesOfUser(userId).transform(
        StreamTransformer<DocumentSnapshot, List<String>>.fromHandlers(
            handleData: (data, sink) {
      var systemsNames = DAL.getAllSystemsOfUserFromDocument(data);
      sink.add(systemsNames);
    }));

    var userSystemsStream =
        Observable.combineLatest2<List<String>, List<System>, List<System>>(
            _userSystemsNames,
            allSystemsStream,
            (userSystems, allSystems) => allSystems
                .where((system) => userSystems.contains(system.systemName))
                .toList());

    // listen to systems stream to update devices
    _userSystems.listen((data) {
      _systemsDevices.sink
          .add(data.map((sys) => sys.devices).expand((i) => i).toList());

      _systemsDevicesTpyes.sink
          .add(data.map((sys) => sys.deviceTypes).expand((i) => i).toList());

      _systemsFieldsNames
          .add(data.map((sys) => sys.fieldNames).expand((i) => i).toList());
    });

    _allSystemsNames.addStream(allSystemNamesStream);
    _userSystemsNames.addStream(userSystemsNamesStream);
    _userSystems.addStream(userSystemsStream);
  }

  @override
  void dispose() async {
    await _currDataStreamSubscription?.cancel();
    await _systemsDevices?.close();
    await _systemsDevicesTpyes?.close();
    await _systemsFieldsNames?.close();
    await _systemsData?.close();
    await _dataTypes?.close();
    await _allSystemsNames?.close();
    await _userSystemsNames.close();
    await _userSystems?.close();
  }

  BehaviorSubject<List<System>> _userSystems = BehaviorSubject<List<System>>();

  final BehaviorSubject<List<String>> _dataTypes =
      BehaviorSubject<List<String>>();
  Stream<List<String>> get dataTypesStream => _dataTypes.stream;

  final BehaviorSubject<List<String>> _allSystemsNames =
      BehaviorSubject<List<String>>();
  Stream<List<String>> get allSystemNamesStream => _allSystemsNames.stream;

  final BehaviorSubject<List<String>> _userSystemsNames =
      BehaviorSubject<List<String>>();
  Stream<List<String>> get userSystemNamesStream => _userSystemsNames.stream;

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
  List<String> _systemsOfUser = <String>[];

  void changeUserSystems() async {
    await DAL.updateUserSystems(_userId, _systemsOfUser);
  }

  void onUserSystemsSelectionChanged(List<String> selected) {
    _systemsOfUser = selected;
  }

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
        ? _userSystems.value
        : _userSystems.value
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
        : _userSystems.value.map((sys) => sys.systemName).toList();

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

    // need penis-scan beacuse when stream merged  streambuilder widget build only at the second stream
    var combinedStream = Observable.merge(_dataStreams.values)
        .scan<List<DataEntry>>((acc, curr, i) {
      // remove all the prev penis data entry from the acc
      acc?.removeWhere(
          (prevDataEntry) => prevDataEntry.systemName == curr.first.systemName);

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
