import 'dart:async';
import 'package:rxdart/rxdart.dart';

import 'bloc_helpers/bloc_provider.dart';

class DatesFilteringBloc implements BlocBase {
  final BehaviorSubject<DateTime> _endTimeDate = BehaviorSubject<DateTime>();
  Stream<DateTime> get endTimeDateStream => _endTimeDate.stream;
  StreamSink<DateTime> get endTimeDateSink => _endTimeDate.sink;

  final BehaviorSubject<DateTime> _startTimeDate = BehaviorSubject<DateTime>();
  Stream<DateTime> get startTimeDateStream => _startTimeDate.stream;
  StreamSink<DateTime> get startTimeDateSink => _startTimeDate.sink;

  @override
  void dispose() async {
    await _startTimeDate?.close();
    await _endTimeDate?.close();
  }
}
