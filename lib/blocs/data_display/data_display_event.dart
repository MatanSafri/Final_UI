import 'package:iot_ui/blocs/bloc_helpers/bloc_event_state.dart';
import 'package:meta/meta.dart';

// abstract class DataDisplayEvent extends BlocEvent {
//   final List<String> selectedSystems;
//   final List<String> allSystems;

//   DataDisplayEvent({this.allSystems, this.selectedSystems});
// }

// class ChangeSelectedSystemsEvent extends DataDisplayEvent {
//   ChangeSelectedSystemsEvent(
//       {List<String> allSystems, List<String> selectedSystems})
//       : super(allSystems: allSystems, selectedSystems: selectedSystems);
// }

// class InitDataDispayEvent extends DataDisplayEvent {
//   InitDataDispayEvent({List<String> allSystems, List<String> selectedSystems})
//       : super(allSystems: allSystems, selectedSystems: selectedSystems);
// }

abstract class DataDisplayEvent extends BlocEvent {}

class InitDataDisplay extends DataDisplayEvent {}

class DisplayData extends DataDisplayEvent {
  DisplayData();
}

class ChangeSystemSelection extends DataDisplayEvent {
  bool selection;
  String systemName;
  ChangeSystemSelection(this.systemName, this.selection);
}

class ChangeDevicesSelection extends DataDisplayEvent {
  bool selection;
  String device;
  ChangeDevicesSelection(this.device, this.selection);
}

class ChangeDevicesTypesSelection extends DataDisplayEvent {
  bool selection;
  String deviceType;
  ChangeDevicesTypesSelection(this.deviceType, this.selection);
}

class ChangeFieldsNamesSelection extends DataDisplayEvent {
  bool selection;
  String fieldName;
  ChangeFieldsNamesSelection(this.fieldName, this.selection);
}

class ChangeStartTimeDate extends DataDisplayEvent {
  DateTime startTimeDate;
  ChangeStartTimeDate(this.startTimeDate);
}

class ChangeEndTimeDate extends DataDisplayEvent {
  DateTime endTimeDate;
  ChangeEndTimeDate(this.endTimeDate);
}

class ClearSystemsSelection extends DataDisplayEvent {}

class ClearDevicesSelection extends DataDisplayEvent {}

class ClearDevicesTypesSelection extends DataDisplayEvent {}

class ClearFieldsNamesSelection extends DataDisplayEvent {}

class ClearDatesSelection extends DataDisplayEvent {}
