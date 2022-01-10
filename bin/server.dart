import 'package:args/args.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:simple_api_dart/data_service.dart';
import 'package:simple_api_dart/todolist.dart';

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
  const version = 'v1';
  if (args[0] == 'todolist') {
    const todolistRoute = '/$version/todolist';
    app.mount(todolistRoute, Todolist(JsonDataService()).router);
  } else {
    print('Specify one of these commands: todoist');
    return;
  }

  io.serve(app, 'localhost', port).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
}
