import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'database.dart';

class PaymentHandler {
  static const _jsonHeaders = {'content-type': 'application/json'};

  Router get router {
    final router = Router();

    // MAKE PAYMENT
    router.post('/', (Request request) async {
      final payload = jsonDecode(await request.readAsString());
      final conn = await Database.getConnection();
      try {
        final bookingId = payload['bookingId'];
        final paidAmount = double.tryParse(payload['amount'].toString()) ?? 0.0;

        await conn.transaction((ctx) async {
          // 1. Verify booking exists and get total amount
          final bookingRes = await ctx.query(
            'SELECT totalAmount FROM bookings WHERE bookingId = ? FOR UPDATE',
            [bookingId],
          );

          if (bookingRes.isEmpty) {
            throw Exception('Booking not found');
          }

          final totalAmount = double.parse(bookingRes.first['totalAmount'].toString());

          // 2. Check amount (allow for minor rounding if needed, but here we expect exact match)
          if ((paidAmount - totalAmount).abs() > 0.01) {
            throw Exception('Payment amount (Rs $paidAmount) does not match booking amount (Rs $totalAmount)');
          }

          // 3. Insert payment
          await ctx.query(
            'INSERT INTO payments (bookingId, method, accountNumber, accountTitle, amount) VALUES (?, ?, ?, ?, ?)',
            [
              bookingId,
              payload['method'],
              payload['accountNumber'],
              payload['accountTitle'],
              paidAmount
            ],
          );

          // 4. Update booking status
          await ctx.query(
            'UPDATE bookings SET status = ? WHERE bookingId = ?',
            ['paid', bookingId],
          );
        });

        return Response.ok(
          jsonEncode({'status': 'success', 'message': 'Payment recorded successfully'}),
          headers: _jsonHeaders,
        );
      } catch (e) {
        return Response(
          e.toString().contains('match') ? 400 : 500,
          body: jsonEncode({'error': e.toString()}),
          headers: _jsonHeaders,
        );
      } finally {
        await conn.close();
      }
    });

    return router;
  }
}
