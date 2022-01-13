import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../core/core.dart';

class Todolist {
  static const _header = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': '*',
    'Access-Control-Allow-Headers': '*'
  };
  final IDataService _db;

  Todolist(this._db);

  Future<Response> _unknownError(Object e, Request request,
      [StackTrace? st]) async {
    final file = File('todolist_unknown_error_log.json');
    if (!file.existsSync()) file.writeAsStringSync(json.encode([]));
    var log = json
        .decode(file.readAsStringSync())
        .cast<Map<String, dynamic>>()
        .toList();
    if (log.length > 100) log.removeAt(0);
    log.add({
      'error': e.toString(),
      'stack': st?.toString(),
      'system': Platform.environment,
      'date': DateTime.now().toIso8601String(),
      'url': request.requestedUri.toString(),
      'method': request.method,
      'headers': request.headers,
    });
    file.writeAsStringSync(json.encode(log));
    return Response(500,
        body:
            'Erro desconhecido, verifique o arquivo ${file.path} para mais detalhes.\n $e');
  }

  FutureOr<Response> getTasks(Request request) {
    try {
      return Response.ok(json.encode(_db.getAll()), headers: _header);
    } on FormatException catch (e) {
      return Response(400, body: 'Invalid format: $e', headers: _header);
    } catch (e, st) {
      return _unknownError(e, request, st);
    }
  }

  FutureOr<Response> createTask(Request request) async {
    try {
      final payload = json.decode(await request.readAsString());
      if (payload['title'] == null || payload['status'] == null) {
        return Response(400, body: 'title or status is null');
      }
      _db.create(payload);
      return Response(201, body: json.encode(payload), headers: _header);
    } on FormatException catch (e) {
      return Response(400, body: 'Invalid format: $e');
    } catch (e, st) {
      return _unknownError(e, request, st);
    }
  }

  FutureOr<Response> updateTask(Request request) async {
    try {
      final payload = json.decode(await request.readAsString());
      if (payload['id'] == null) return Response(400, body: 'id is null');
      _db.update(payload);
      return Response.ok(json.encode(payload), headers: _header);
    } on NotFound catch (e) {
      return Response(400, body: e.message);
    } on FormatException catch (e) {
      return Response(400, body: 'Invalid format: $e');
    } catch (e, st) {
      return _unknownError(e, request, st);
    }
  }

  FutureOr<Response> deleteTask(Request request) async {
    try {
      final payload = json.decode(await request.readAsString());
      _db.delete("${payload['id']}");
      return Response.ok('Deleted');
    } on NotFound catch (e) {
      return Response(400, body: e.message);
    } on FormatException catch (e) {
      return Response(400, body: 'Invalid format: $e');
    } catch (e, st) {
      return await _unknownError(e, request, st);
    }
  }

  Router get router {
    final router = Router();
    router.get('/', getTasks);
    router.post('/', createTask);
    router.put('/', updateTask);
    router.delete('/', deleteTask);
    return router;
  }
}
