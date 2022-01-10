import 'dart:async';

abstract class IDataService {
  FutureOr<List<Map<String, dynamic>?>> getAll({int? index, int? limit});
  FutureOr<Map<String, dynamic>>? getByKey(String key);
  FutureOr create(Map<String, dynamic> item);
  FutureOr update(Map<String, dynamic> item);
  FutureOr delete(String key);
}
