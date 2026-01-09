// dart run tool/dev_proxy.dart
// flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8081
import 'dart:async';
import 'dart:io';

import 'package:http/io_client.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_proxy/shelf_proxy.dart';

const _defaultTarget = 'https://tripsync-95ol.onrender.com';

Future<void> main(List<String> args) async {
  final targetBase = args.isNotEmpty ? args.first : _defaultTarget;
  final target = Uri.parse(targetBase);

  final handler = const Pipeline()
      .addMiddleware(_cors())
      .addHandler(_router(target));

  final server = await shelf_io.serve(
    handler,
    InternetAddress.loopbackIPv4,
    8081,
  );

  // Helps when running in terminals that don’t show log output well.
  // ignore: avoid_print
  print(
    'TripSync dev proxy listening on http://${server.address.host}:${server.port} -> $targetBase',
  );
}

Handler _router(Uri target) {
  final httpClient = HttpClient()
    ..userAgent = 'TripSyncDevProxy/1.0'
    ..idleTimeout = const Duration(seconds: 30);

  final proxy = proxyHandler(target.toString(), client: IOClient(httpClient));

  return (Request req) async {
    // Respond to browser CORS preflight locally.
    if (req.method.toUpperCase() == 'OPTIONS') {
      return Response(204);
    }

    return proxy(req);
  };
}

Middleware _cors() {
  return (Handler innerHandler) {
    return (Request request) async {
      final response = await innerHandler(request);

      // In dev we allow all origins. If you want to lock it down:
      // final origin = request.headers['origin'];
      // and echo it back only when it matches.
      const allowOrigin = '*';

      final headers = <String, String>{
        ...response.headers,
        'Access-Control-Allow-Origin': allowOrigin,
        'Access-Control-Allow-Methods':
            'GET, POST, PUT, PATCH, DELETE, OPTIONS',
        'Access-Control-Allow-Headers':
            'Origin, Content-Type, Accept, Authorization',
        'Access-Control-Max-Age': '86400',
      };

      return response.change(headers: headers);
    };
  };
}
