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

class ChangeSystemsSelection extends DataDisplayEvent {
  List<String> newSystems;
  ChangeSystemsSelection({@required this.newSystems});
}
