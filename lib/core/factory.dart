import 'package:simple_api_dart/core/core.dart';
import 'package:simple_api_dart/service/json_data_service.dart';

abstract class Factory {
  static IDataService get dataService => JsonDataService();
}
