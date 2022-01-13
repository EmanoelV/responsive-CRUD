import 'dart:convert';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:simple_api_dart/core/core.dart';
import 'package:simple_api_dart/module/todolist.dart';

void main(List<String> arguments) {
  var parser = ArgParser();
  parser.addCommand('args');
  var args = parser.parse(arguments).arguments;
  if (args.isEmpty) {
    print('Specify one of these commands: todoist');
    return;
  }
  var port = args.length == 2 ? int.parse(args[1]) : 7777;
  var app = Router();
  if (args[0] == 'todolist') {
    app.mount(Config.todolistPath, Todolist(Factory.dataService).router);
  } else {
    print('Specify one of these commands: todoist');
    return;
  }

  app.options(
      '/<cors|.*>',
      (_) => Response(200,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': '*',
            'Access-Control-Allow-Headers': '*'
          },
          body: json.encode({'status': '200'})));

  io.serve(app, 'localhost', port).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
}
