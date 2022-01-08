import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;

void main(List<String> arguments) {
  var parser = ArgParser();
  parser.addCommand('args');
  var args = parser.parse(arguments).arguments;
  if (args[0] != 'todolist') {
    print("please run with 'todolist'");
  }

  var app = Router();
  if (!File('data.json').existsSync()) {
    File('data.json').writeAsStringSync(json.encode([]));
  }
  List data = json.decode(File('data.json').readAsStringSync());
  const version = 'v1';
  const route = '/$version/todolist';
  const header = {'Content-Type': 'application/json'};

  Future updateDatabase() => Future.delayed(Duration(minutes: 1)).then((_) {
        File('data.json').writeAsStringSync(json.encode(data));
        data = json.decode(File('data.json').readAsStringSync());
        updateDatabase();
      });
  updateDatabase();

  app.get(route, (Request request) {
    return Response.ok(json.encode(data), headers: header);
  });

  app.post(route, (Request request) async {
    final Map<String, dynamic> payload =
        json.decode(await request.readAsString());
    if (payload['title'] == null || payload['status'] == null) {
      return Response(400, body: 'bad request, title or status is null');
    }
    payload['id'] = data.isEmpty ? 1 : data.last['id'] + 1;
    payload['createdAt'] = DateTime.now().toIso8601String();
    payload['updatedAt'] = DateTime.now().toIso8601String();
    data.add(payload);
    return Response(201, body: json.encode(payload), headers: header);
  });

  app.put(route, (Request request) async {
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

  app.delete(route, (Request request) async {
    final payload = json.decode(await request.readAsString());
    final oldSize = data.length;
    data.removeWhere((data) => data['id'] == payload['id']);
    if (oldSize == data.length) {
      return Response(400, body: 'bad request, id not found in database');
    }
    return Response.ok('Deleted');
  });

  io.serve(app, 'localhost', 7777).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
}
