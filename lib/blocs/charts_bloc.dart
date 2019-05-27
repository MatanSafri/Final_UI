import 'package:rxdart/rxdart.dart';
import 'bloc_helpers/bloc_provider.dart';

class ChartsBloc implements BlocBase {
  BehaviorSubject<String> _chartTypeController = BehaviorSubject<String>();
  Stream<String> get chartType => _chartTypeController;
  Function(String) get onchartTypeChanged => _chartTypeController.sink.add;

  BehaviorSubject<String> _fieldController = BehaviorSubject<String>();
  Stream<String> get field => _fieldController;
  Function(String) get onFieldChanged => _fieldController.sink.add;

  // BehaviorSubject<String> _numberFieldNameController =
  //     BehaviorSubject<String>();
  // Stream<String> get numberFieldName => _numberFieldNameController;
  //   Function(String) get onNumberFieldNameChanged => _numberFieldNameController.sink.add;

  //final List<DataEntry> data;

  @override
  void dispose() {
    _chartTypeController?.close();
    _fieldController?.close();
    //_numberFieldNameController?.close();
  }

  //ChartsBloc(this.data);
}
