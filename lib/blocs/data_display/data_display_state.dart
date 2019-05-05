import 'dart:collection';

import 'package:iot_ui/blocs/bloc_helpers/bloc_event_state.dart';
import 'package:meta/meta.dart';

class DataDisplayState extends BlocState {
  final UnmodifiableListView<String> systemNames;
  final DateTime startDateTime;
  final DateTime endDateTime;

  DataDisplayState.init()
      : systemNames = UnmodifiableListView<String>(List<String>()),
        startDateTime = null,
        endDateTime = null;

  DataDisplayState(List<String> sysNames, DateTime start, DateTime end)
      : systemNames = UnmodifiableListView<String>(sysNames),
        startDateTime = start,
        endDateTime = end;
}
