import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import '../lib/auth_handler.dart';
import '../lib/room_handler.dart';
import '../lib/booking_handler.dart';
import '../lib/payment_handler.dart';
import '../lib/database.dart';

const _corsHeaders = <String, String>{
  'access-control-allow-origin': '*',
  'access-control-allow-methods': 'GET,POST,PUT,PATCH,DELETE,OPTIONS',
  'access-control-allow-headers': 'origin, content-type, accept, authorization',
};

Middleware _cors() {
  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method.toUpperCase() == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }

      final response = await innerHandler(request);
      final headers = <String, String>{...response.headers, ..._corsHeaders};
      return response.change(headers: headers);
    };
  };
}

void main() async {
  final router = Router();

  // HEALTH CHECK (includes DB connectivity)
  router.get('/health', (Request request) async {
    try {
      final conn = await Database.getConnection();
      try {
        await conn.query('SELECT 1');
      } finally {
        await conn.close();
      }

      return Response.ok(
        jsonEncode({'status': 'ok'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  });

  // AUTH ROUTES
  router.mount('/auth/', AuthHandler().router);

  // ROOM ROUTES
  router.mount('/rooms', RoomHandler().router);
  router.mount('/rooms/', RoomHandler().router);

  // BOOKING ROUTES
  router.mount('/booking', BookingHandler().router);
  router.mount('/booking/', BookingHandler().router);
  router.mount('/bookings', BookingHandler().router); // For get my bookings by phone
  router.mount('/bookings/', BookingHandler().router);

  // PAYMENT ROUTES
  router.mount('/payment', PaymentHandler().router);
  router.mount('/payment/', PaymentHandler().router);

  final handler = const Pipeline()
      .addMiddleware(_cors())
      .addMiddleware(logRequests())
      .addHandler(router);

  // Use PORT from environment or default to 8080
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, '0.0.0.0', port);
  
  print('Server listening on http://${server.address.host}:${server.port}');
}
