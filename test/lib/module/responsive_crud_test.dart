import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:simple_api_dart/core/core.dart';
import 'package:simple_api_dart/module/responsive_crud.dart';
import 'package:test/test.dart';

void main() {
  final todolist = ResponsiveCrud(Factory.dataService);
  final path = 'http://localhost:7777' + Config.todolistPath;

  void resetDatabase() {
    final file = File('data.json');
    file.writeAsStringSync(json.encode([]));
  }

  group('Data Sanitization', () {
    resetDatabase();
    test('HTML tags sanitization in post', () async {
      final response =
          await todolist.createTask(Request('POST', Uri.parse(path),
              body: json.encode({
                'title': '<tagHtml>aaa</tagHtml>',
                'status': '<script src="https://pepepi.popopo">ssss',
                'extraItemUnic': '<script src="https://pepepi.popopo">',
                '<>': '<>',
                '&': '&'
              })));
      expect(response.statusCode, equals(201));
      final responseGet =
          await todolist.getTasks(Request('GET', Uri.parse(path)));
      final responseGetJson = json.decode(await responseGet.readAsString());
      expect(responseGet.statusCode, equals(200));
      final Map<String, dynamic> responseItem = responseGetJson
          .firstWhere((element) => element['extraItemUnic'] != null);
      expect(
          responseItem['title'], equals('&lt;tagHtml&gt;aaa&lt;/tagHtml&gt;'));
      expect(responseItem['status'],
          equals('&lt;script src="https://pepepi.popopo"&gt;ssss'));
      expect(responseItem['extraItemUnic'],
          equals('&lt;script src="https://pepepi.popopo"&gt;'));
      expect(responseItem.keys.toList()[3], equals('&lt;&gt;'));
      expect(responseItem.keys.toList()[4], equals('&amp;'));
      expect(responseItem['&lt;&gt;'], equals('&lt;&gt;'));
      expect(responseItem['&amp;'], equals('&amp;'));
    });

    test('HTML tags sanitization in put', () async {
      final response = await todolist.updateTask(Request('PUT', Uri.parse(path),
          body: json.encode({
            'id': '1',
            'title': '<tagHtml>aaa</tagHtml>',
            'status': '<script src="https://pepepi.popopo">ssss',
            'extraItemUnic': '<script src="https://pepepi.popopo">',
            '<>': '<>',
            '&': '&'
          })));
      expect(response.statusCode, equals(200));
      final responseGet =
          await todolist.getTasks(Request('GET', Uri.parse(path)));
      final responseGetJson = json.decode(await responseGet.readAsString());
      expect(responseGet.statusCode, equals(200));
      final Map<String, dynamic> responseItem = responseGetJson
          .firstWhere((element) => element['extraItemUnic'] != null);
      expect(
          responseItem['title'], equals('&lt;tagHtml&gt;aaa&lt;/tagHtml&gt;'));
      expect(responseItem['status'],
          equals('&lt;script src="https://pepepi.popopo"&gt;ssss'));
      expect(responseItem['extraItemUnic'],
          equals('&lt;script src="https://pepepi.popopo"&gt;'));
      expect(responseItem.keys.toList()[3], equals('&lt;&gt;'));
      expect(responseItem.keys.toList()[4], equals('&amp;'));
      expect(responseItem['&lt;&gt;'], equals('&lt;&gt;'));
      expect(responseItem['&amp;'], equals('&amp;'));
    });
  });

  group('Todolist requests', () {
    resetDatabase();
    final goodGetRequests = [
      Request('GET', Uri.parse(path)),
    ];

    final goodPostRequests = [
      Request('POST', Uri.parse(path),
          body: json.encode({'title': 'test', 'status': 'open'})),
      Request('POST', Uri.parse(path),
          body: json.encode({'title': 'test', 'status': 'open'})),
      Request('POST', Uri.parse(path),
          body: json.encode(
              {'title': 'test', 'status': 'open', 'extraItem': 'extra'})),
    ];

    final goodPutRequests = [
      Request('PUT', Uri.parse(path),
          body: json.encode({'title': 'test2', 'id': '1'})),
      Request('PUT', Uri.parse(path),
          body: json.encode({'title': 'test', 'id': 1})),
      Request('PUT', Uri.parse(path),
          body: json.encode({
            'title': 'test',
            'status': 'open',
            'extraItem': 'extra',
            'id': '1'
          })),
    ];

    final goodDeleteRequests = [
      Request('DELETE', Uri.parse(path), body: json.encode({'id': 1})),
      Request('DELETE', Uri.parse(path), body: json.encode({'id': '2'})),
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

    test('deleteTask', () async {
      goodDeleteRequests.forEach((element) async {
        final response = await todolist.deleteTask(element);
        final responseBody = await response.readAsString();
        expect(response.statusCode, equals(200));
        expect(responseBody, isNotEmpty);
      });
    });
  });
}
