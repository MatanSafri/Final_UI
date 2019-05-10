import 'dart:collection';

import 'package:iot_ui/blocs/bloc_helpers/bloc_event_state.dart';
import 'package:meta/meta.dart';

class DataDisplayState extends BlocState {
  final UnmodifiableListView<String> devices;
  final UnmodifiableListView<String> systemNames;
  final UnmodifiableListView<String> fieldNames;
  final UnmodifiableListView<String> deviceTypes;
  final DateTime startDateTime;
  final DateTime endDateTime;

  DataDisplayState.init()
      : systemNames = UnmodifiableListView<String>(List<String>()),
        devices = UnmodifiableListView<String>(List<String>()),
        deviceTypes = UnmodifiableListView<String>(List<String>()),
        fieldNames = UnmodifiableListView<String>(List<String>()),
        startDateTime = null,
        endDateTime = null;

  DataDisplayState(List<String> sysNames, List<String> devicesId,
      List<String> types, List<String> fields, DateTime start, DateTime end)
      : systemNames = UnmodifiableListView<String>(sysNames),
        devices = UnmodifiableListView<String>(devicesId),
        fieldNames = UnmodifiableListView<String>(fields),
        deviceTypes = UnmodifiableListView<String>(types),
        startDateTime = start,
        endDateTime = end;
}
