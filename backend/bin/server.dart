import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// Configure routes.
final _router = Router(notFoundHandler: _notFoundHandle)
  ..get('/', _rootHandler)
  ..get('/api/v1/check', _checkHandler)
  ..get('/api/v1/echo/<message>', _echoHandler)
  ..post('/api/v1/submit', _submitHandler);

final _headers = {'ContentType': 'application/json'};

Response _notFoundHandle(Request req) {
  return Response.notFound(
      'Khong the tim thay duong dan "${req.url}" tren server');
}

Response _rootHandler(Request req) {
  return Response.ok(
    json.encode({'message': 'Hello, world'}),
    headers: _headers,
  );
}

Response _checkHandler(Request req) {
  return Response.ok(
    json.encode({'message': 'Chao mung ban den voi ung dung web dong'}),
    headers: _headers,
  );
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

Future<Response> _submitHandler(Request req) async {
  try {
    final payload = await req.readAsString();
    final data = json.decode(payload);
    final name = data['name'] as String?;

    if (name != null && name.isNotEmpty) {
      final response = {'message': 'Chao mung $name'};
      return Response.ok(
        json.encode(response),
        headers: _headers,
      );
    }else{
      final response = {'message': 'Server khong nhan duoc ten cua ban'};
      return Response.badRequest(
        body: json.encode(response),
        headers: _headers,
      );
    }
  } catch (e) {
    final response = {'message': 'Yeu cau khong hop le. Loi ${e.toString()}'};
    return Response.badRequest(
      body: json.encode(response),
      headers: _headers,
    );
  }
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler =
      Pipeline().addMiddleware(logRequests()).addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
