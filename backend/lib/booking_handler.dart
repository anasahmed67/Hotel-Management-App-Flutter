import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'database.dart';

class BookingHandler {
  static const _jsonHeaders = {'content-type': 'application/json'};

  Router get router {
    final router = Router();

    // GET ALL BOOKINGS (admin/reporting)
    router.get('/', (Request request) async {
      final conn = await Database.getConnection();
      try {
        final results = await conn.query('SELECT * FROM bookings ORDER BY created_at DESC');
        final bookings = results.map((row) => {
          'bookingId': row['bookingId'].toString(),
          'userName': row['userName'],
          'phone': row['phone'],
          'nic': row['nic'],
          'roomId': row['roomId'].toString(),
          'checkIn': row['checkIn'].toString(),
          'checkOut': row['checkOut'].toString(),
          'roomCount': row['roomCount'],
          'persons': row['persons'],
          'totalAmount': row['totalAmount'],
          'status': row['status'],
          'assignedRoom': row['assignedRoom'],
        }).toList();

        return Response.ok(jsonEncode(bookings), headers: _jsonHeaders);
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: _jsonHeaders,
        );
      } finally {
        await conn.close();
      }
    });

    // CREATE BOOKING
    router.post('/', (Request request) async {
      final payload = jsonDecode(await request.readAsString());
      final conn = await Database.getConnection();
      try {
        final roomId = payload['roomId'];
        final checkInStr = payload['checkIn'];
        final checkOutStr = payload['checkOut'];
        final requestedRooms = int.tryParse(payload['roomCount'].toString()) ?? 1;

        // 1. Basic Validation
        final checkIn = DateTime.parse(checkInStr);
        final checkOut = DateTime.parse(checkOutStr);

        if (checkOut.isBefore(checkIn) || checkOut.isAtSameMomentAs(checkIn)) {
          return Response(400,
              body: jsonEncode({'error': 'Check-out date must be after check-in date'}),
              headers: _jsonHeaders);
        }

        final today = DateTime.now();
        final startOfToday = DateTime(today.year, today.month, today.day);
        if (checkIn.isBefore(startOfToday)) {
          return Response(400,
              body: jsonEncode({'error': 'Check-in date cannot be in the past'}),
              headers: _jsonHeaders);
        }

        // 2. Check Availability and Create Booking (Atomic)
        int? newId;
        await conn.transaction((ctx) async {
          final roomRes = await ctx.query('SELECT totalRooms FROM rooms WHERE id = ? FOR UPDATE', [roomId]);
          if (roomRes.isEmpty) {
            throw Exception('Room type not found');
          }
          final totalRooms = roomRes.first['totalRooms'] as int;

          final bookedRes = await ctx.query(
            'SELECT SUM(roomCount) as booked FROM bookings WHERE roomId = ? AND status NOT IN ("cancelled") AND (checkIn < ? AND checkOut > ?)',
            [roomId, checkOutStr, checkInStr],
          );
          final bookedRooms = int.tryParse(bookedRes.first['booked']?.toString() ?? '0') ?? 0;

          if (totalRooms - bookedRooms < requestedRooms) {
            throw Exception('Not enough rooms available for these dates. (Available: ${totalRooms - bookedRooms})');
          }

          final result = await ctx.query(
            'INSERT INTO bookings (userName, phone, nic, roomId, checkIn, checkOut, roomCount, persons, totalAmount, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
              payload['userName'],
              payload['phone'],
              payload['nic'],
              roomId,
              checkInStr,
              checkOutStr,
              requestedRooms,
              payload['persons'],
              payload['totalAmount'],
              payload['status'] ?? 'pending'
            ],
          );
          newId = result.insertId;
        });

        return Response.ok(
          jsonEncode({
            'status': 'success',
            'message': 'Booking created',
            'bookingId': newId.toString()
          }),
          headers: _jsonHeaders,
        );
      } catch (e) {
        return Response(
          e.toString().contains('available') ? 400 : 500,
          body: jsonEncode({'error': e.toString()}),
          headers: _jsonHeaders,
        );
      } finally {
        await conn.close();
      }
    });

    // CANCEL BOOKING
    router.put('/cancel/<id>', (Request request, String id) async {
      final conn = await Database.getConnection();
      try {
        await conn.query(
          'UPDATE bookings SET status = "cancelled" WHERE bookingId = ?',
          [id],
        );
        return Response.ok(
          jsonEncode({'status': 'success', 'message': 'Booking cancelled'}),
          headers: _jsonHeaders,
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: _jsonHeaders,
        );
      } finally {
        await conn.close();
      }
    });

    // GET MY BOOKINGS
    router.get('/<phone>', (Request request, String phone) async {
      final conn = await Database.getConnection();
      try {
        final results = await conn.query('SELECT * FROM bookings WHERE phone = ? ORDER BY created_at DESC', [phone]);
        final bookings = results.map((row) => {
          'bookingId': row['bookingId'].toString(),
          'userName': row['userName'],
          'phone': row['phone'],
          'nic': row['nic'],
          'roomId': row['roomId'].toString(),
          'checkIn': row['checkIn'].toString(),
          'checkOut': row['checkOut'].toString(),
          'roomCount': row['roomCount'],
          'persons': row['persons'],
          'totalAmount': row['totalAmount'],
          'status': row['status'],
          'assignedRoom': row['assignedRoom'],
        }).toList();

        return Response.ok(jsonEncode(bookings), headers: _jsonHeaders);
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: _jsonHeaders,
        );
      } finally {
        await conn.close();
      }
    });

    // UPDATE STATUS
    router.put('/status', (Request request) async {
      final payload = jsonDecode(await request.readAsString());
      final conn = await Database.getConnection();
      try {
        await conn.query(
          'UPDATE bookings SET status = ? WHERE bookingId = ?',
          [payload['status'], payload['bookingId']],
        );
        return Response.ok(
          jsonEncode({'status': 'success', 'message': 'Status updated'}),
          headers: _jsonHeaders,
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: _jsonHeaders,
        );
      } finally {
        await conn.close();
      }
    });

    // ASSIGN ROOM
    router.put('/assign', (Request request) async {
      final payload = jsonDecode(await request.readAsString());
      final conn = await Database.getConnection();
      try {
        await conn.query(
          "UPDATE bookings SET assignedRoom = ?, status = IF(status IN ('pending','waiting'), 'confirmed', status) WHERE bookingId = ?",
          [payload['room'], payload['bookingId']],
        );
        return Response.ok(
          jsonEncode({'status': 'success', 'message': 'Room assigned'}),
          headers: _jsonHeaders,
        );
      } catch (e) {
        return Response.internalServerError(
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
