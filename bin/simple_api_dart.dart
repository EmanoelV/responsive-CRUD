import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;

void main(List<String> arguments) {
  var app = Router();
  const version = 'v1';
  const route = '/$version/todolist';

  app.get(route, (request) {
    return Response.ok(json.encode({'msg': 'Hello World!'}),
        headers: {'content-type': 'application/json'});
  });

  app.post(route, (request) {
    return Response.ok(json.encode({'msg': 'Hello World!'}),
        headers: {'content-type': 'application/json'});
  });

  app.put(route, (request) {
    return Response.ok(json.encode({'msg': 'Hello World!'}),
        headers: {'content-type': 'application/json'});
  });

  app.delete(route, (request) {
    return Response.ok(json.encode({'msg': 'Hello World!'}),
        headers: {'content-type': 'application/json'});
  });

  io.serve(app, 'localhost', 7777).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
}
