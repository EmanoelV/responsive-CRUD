import 'dart:async';
import 'dart:convert';
import 'dart:io';

class JsonDataService implements IDataService {
  final _file = File('data.json');

  JsonDataService() {
    if (!_file.existsSync()) {
      _file.writeAsStringSync(json.encode([]));
    }
    print('JSON database initialized');
  }

  @override
  void create(Map<String, dynamic> item) {
    final data = getAll();
    item['id'] = data.isEmpty ? 1 : data.last?['id'] + 1;
    item['createdAt'] = DateTime.now().toIso8601String();
    item['updatedAt'] = DateTime.now().toIso8601String();
    data.add(item);
    _file.writeAsStringSync(json.encode(data));
  }

  @override
  void delete(String key) {
    final data = getAll();
    final oldSize = data.length;
    if (data.isEmpty) throw NotFound('No data to delete');
    data.removeWhere((data) => data?['id'].toString() == key);
    if (data.length == oldSize) throw NotFound('No data to delete');
    _file.writeAsStringSync(json.encode(data));
  }

  @override
  List<Map<String, dynamic>?> getAll({int? index, int? limit}) {
    return json
        .decode(_file.readAsStringSync())
        .cast<Map<String, dynamic>>()
        .toList();
  }

  @override
  Map<String, dynamic>? getByKey(String key) {
    final data = getAll();
    return data.firstWhere((data) => data?['id'] == key);
  }

  @override
  void update(Map<String, dynamic> item) {
    final data = getAll();
    if (data.isEmpty) throw NotFound('No data to update');
    final index = data.indexWhere((element) => element?['id'] == item['id']);
    if (index == -1) throw NotFound('Item not found');
    item['updatedAt'] = DateTime.now().toIso8601String();
    data[index]?.addAll(item);
    _file.writeAsStringSync(json.encode(data));
  }
}

abstract class IDataService {
  FutureOr<List<Map<String, dynamic>?>> getAll({int? index, int? limit});
  FutureOr<Map<String, dynamic>>? getByKey(String key);
  FutureOr create(Map<String, dynamic> item);
  FutureOr update(Map<String, dynamic> item);
  FutureOr delete(String key);
}

class NotFound implements Exception {
  final String message;
  NotFound(this.message);
}
