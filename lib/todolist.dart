import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:simple_api_dart/data_service.dart';

class Todolist {
  static const header = {'Content-Type': 'application/json'};
  final db = JsonDataService();

  Router get router {
    final router = Router();

    router.get('/', (Request request) {
      return Response.ok(json.encode(db.getAll()));
    });

    router.post('/', (Request request) async {
      final payload = json.decode(await request.readAsString());
      if (payload['title'] == null || payload['status'] == null) {
        return Response(400, body: 'title or status is null');
      }
      db.create(payload);
      return Response(201, body: json.encode(payload), headers: header);
    });

    router.put('/', (Request request) async {
      final payload = json.decode(await request.readAsString());
      if (payload['id'] == null) {
        return Response(400, body: 'id is null');
      }
      try {
        db.update(payload);
      } on NotFound catch (e) {
        return Response(400, body: e.message);
      }

      return Response.ok(json.encode(payload), headers: header);
    });

    router.delete('/', (Request request) async {
      final payload = json.decode(await request.readAsString());
      try {
        db.delete("${payload['id']}");
      } on NotFound catch (e) {
        return Response(400, body: e.message);
      }

      return Response.ok('Deleted');
    });

    return router;
  }
}
