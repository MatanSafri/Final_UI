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

  BehaviorSubject<QuerySnapshot> _systemsData =
      BehaviorSubject<QuerySnapshot>();
  Stream<QuerySnapshot> get systemsDataStream => _systemsData.stream;

  @override
  Stream<DataDisplayState> eventHandler(
      DataDisplayEvent event, DataDisplayState currentState) async* {
    if (event is InitDataDisplay) {
      // inform that we are loading
      //yield DataDisplayState.loadingSystems();
      //_allSystemNames.add(event.newSystem);
      //_systemNames.sink.add();

      // Getting all the systems
      //var allSystems = await (DAL.getSystemsNames().toList());
    } else if (event is ChangeSystemsSelection) {
      // close the prev listener
      //_systemsData.close();
      //_systemsData = BehaviorSubject<QuerySnapshot>();

      // List<Stream<QuerySnapshot>> streams = List<Stream<QuerySnapshot>>();

      // event.newSystems.forEach((systemName) {
      //   streams.add(DAL.getDataCollection(systemName));
      // });

      //_systemsData.addStream(Observable.merge(streams));
      // await _systemsData.sink?.close();
      // await _systemsData.close();

      // TODO: handle closing the prev streams
      // TODO: optimaze by using lastState dont add existing streams - maybe need to save originals streams

      // margeing all the data streams of the systems to one and add it to _systemsData
      //await _systemsData.drain();

      _systemsData = BehaviorSubject<QuerySnapshot>();
      print("stream: ${event.newSystems.toString()}\n");
      // _systemsData.addStream(Observable.merge(event.newSystems
      //     .map((systemName) => DAL.getDataCollection(systemName))));

      List<Stream<QuerySnapshot>> streams = List<Stream<QuerySnapshot>>();

      event.newSystems.forEach((systemName) {
        streams.add(DAL.getDataCollection(systemName));
      });

      //_systemsData.addStream(x);

      yield DataDisplayState.systemsSelected(currentState.systemNames);
    }
  }
}
