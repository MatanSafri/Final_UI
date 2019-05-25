import 'dart:async';
import 'package:rxdart/rxdart.dart';

import 'bloc_helpers/bloc_provider.dart';

class FilteringBloc implements BlocBase {
  BehaviorSubject<List<String>> _allItemsController =
      BehaviorSubject<List<String>>();
  Stream<List<String>> get allItems => _allItemsController;

  BehaviorSubject<List<String>> _selectedItemsController =
      BehaviorSubject<List<String>>();
  Stream<List<String>> get selectedItems => _selectedItemsController;

  final Map<String, BehaviorSubject<bool>> _checkStateItems =
      Map<String, BehaviorSubject<bool>>();
  Map<String, Stream<bool>> get checkStateSystemNamesStream => _checkStateItems
      .map<String, Stream<bool>>((key, value) => MapEntry(key, value.stream));

  Map<String, StreamSink<bool>> get checkStateSystemNamesSink =>
      _checkStateItems.map<String, StreamSink<bool>>(
          (key, value) => MapEntry(key, value.sink));

  FilteringBloc(Stream<List<String>> stream) {
    // init the selected stream - no selected items in the start
    _selectedItemsController.add(List<String>());

    _allItemsController.listen((systemNames) {
      _checkStateItems.clear();
      systemNames.forEach((systemName) {
        var stream = BehaviorSubject<bool>();
        _checkStateItems.putIfAbsent(systemName, () => stream);

        stream.listen((selection) {
          if (selection) {
            _selectedItemsController.sink
                .add(_selectedItemsController.value + [systemName]);
          } else {
            var selectedItems = _selectedItemsController.value;
            selectedItems.remove(systemName);
            _selectedItemsController.sink.add(selectedItems);
          }
        });
      });
    });

    _allItemsController.addStream(stream);
  }

  @override
  void dispose() async {
    for (var bs in _checkStateItems.values) await bs?.close();
    await _selectedItemsController?.close();
    await _allItemsController?.close();
  }
}
