import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class Todolist {
  static const header = {'Content-Type': 'application/json'};
  late List data;
  Todolist() {
    if (!File('data.json').existsSync()) {
      File('data.json').writeAsStringSync(json.encode([]));
    }
    data = json.decode(File('data.json').readAsStringSync());
    updateDatabase();
  }

  Future updateDatabase() => Future.delayed(Duration(minutes: 1)).then((_) {
        File('data.json').writeAsStringSync(json.encode(data));
        data = json.decode(File('data.json').readAsStringSync());
        updateDatabase();
      });

  Router get router {
    final router = Router();

    router.get('/', (Request request) {
      return Response.ok(json.encode(data), headers: header);
    });

    router.post('/', (Request request) async {
      final payload = json.decode(await request.readAsString());
      if (payload['title'] == null || payload['status'] == null) {
        return Response(400, body: 'bad request, title or status is null');
      }
      payload['id'] = data.isEmpty ? 1 : data.last['id'] + 1;
      payload['createdAt'] = DateTime.now().toIso8601String();
      payload['updatedAt'] = DateTime.now().toIso8601String();
      data.add(payload);
      return Response(201, body: json.encode(payload), headers: header);
    });

    router.put('/', (Request request) async {
      final payload = json.decode(await request.readAsString());
      if (payload['id'] == null) {
        return Response(400, body: 'bad request, id is null');
      }
      final task = data.firstWhere((task) => task['id'] == payload['id'],
          orElse: () => null);
      if (task == null) {
        return Response(404, body: 'task not found');
      }
      payload['updatedAt'] = DateTime.now().toIso8601String();
      data[data.indexWhere((element) => element['id'] == payload['id'])]
          .addAll(payload);

      return Response.ok(json.encode(payload), headers: header);
    });

    router.delete('/', (Request request) async {
      final payload = json.decode(await request.readAsString());
      final oldSize = data.length;
      data.removeWhere((data) => data['id'] == payload['id']);
      if (oldSize == data.length) {
        return Response(400, body: 'bad request, id not found in database');
      }
      return Response.ok('Deleted');
    });

    return router;
  }
}
