import 'package:iot_ui/blocs/bloc_helpers/bloc_event_state.dart';
import 'package:meta/meta.dart';

class DataDisplayState extends BlocState {
  // final bool isLoading;
  // final Map<String, dynamic> data;
  // final List<String> systemNames;

  // DataDisplayState(
  //     {this.isLoading: false, this.data, @required this.systemNames});

  // factory DataDisplayState.loadingData(List<String> systemNames) {
  //   return DataDisplayState(
  //       isLoading: false,
  //       data: Map<String, dynamic>(),
  //       systemNames: systemNames);
  // }

  // factory DataDisplayState.systemsSelected(List<String> systemNames) {
  //   return DataDisplayState(systemNames: systemNames);
  // }
  //final bool isLoading;

  //TODO: make diffrent constructors
  Map<String, dynamic> data;
  List<String> systemNames;

  DataDisplayState(Map<String, dynamic> _data, List<String> _systemNames) {
    data = _data;
    systemNames = _systemNames;
  }
}
