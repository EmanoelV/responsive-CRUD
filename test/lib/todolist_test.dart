import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:simple_api_dart/core/core.dart';
import 'package:simple_api_dart/service/json_data_service.dart';
import 'package:simple_api_dart/todolist.dart';
import 'package:test/test.dart';

void main() {
  final todolist = Todolist(JsonDataService());
  final path = 'http://localhost:7777' + Config.todolistPath;
  group('Todolist', () {
    final goodGetRequests = [
      Request('GET', Uri.parse(path)),
      Request('GET', Uri.parse(path + '?page=1'))
    ];

    final goodPostRequests = [
      Request('POST', Uri.parse(path),
          body: json.encode({'title': 'test', 'status': 'open'})),
      Request('POST', Uri.parse(path + '?page=1'),
          body: json.encode({'title': 'test', 'status': 'open'})),
      Request('POST', Uri.parse(path),
          body: json.encode(
              {'title': 'test', 'status': 'open', 'extraItem': 'extra'})),
    ];

    final goodPutRequests = [
      Request('PUT', Uri.parse(path),
          body: json.encode({'title': 'test2', 'id': '1'})),
      Request('PUT', Uri.parse(path + '/1?page=1'),
          body: json.encode({'title': 'test', 'id': 1})),
      Request('PUT', Uri.parse(path + '/1'),
          body: json.encode({
            'title': 'test',
            'status': 'open',
            'extraItem': 'extra',
            'id': '1'
          })),
    ];

    test('getTasks', () async {
      goodGetRequests.forEach((element) async {
        final response = await todolist.getTasks(element);
        final responseBody = await response.readAsString();
        final responseIdealRequest =
            await (await todolist.getTasks(Request('GET', Uri.parse(path))))
                .readAsString();

        expect(response.statusCode, equals(200));
        expect(responseBody, isNotEmpty);
        expect(responseBody, responseIdealRequest);
      });
    });

    test('createTask', () async {
      goodPostRequests.forEach((element) async {
        final response = await todolist.createTask(element);
        final responseBody = await response.readAsString();
        expect(response.statusCode, equals(201));
        expect(responseBody, isNotEmpty);
      });
    });

    test('updateTask', () async {
      goodPutRequests.forEach((element) async {
        final response = await todolist.updateTask(element);
        final responseBody = await response.readAsString();
        expect(response.statusCode, equals(200));
        expect(responseBody, isNotEmpty);
      });
    });
  });
}
