import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mysql1/mysql1.dart';
import 'database.dart';

class RoomHandler {
  static const _jsonHeaders = {'content-type': 'application/json'};

  int? _boolToTinyInt(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value ? 1 : 0;
    if (value is int) return value == 0 ? 0 : 1;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      if (lower == 'true' || lower == '1') return 1;
      if (lower == 'false' || lower == '0') return 0;
    }
    return null;
  }

  String? _dbValueToString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Blob) return value.toString();
    if (value is List<int>) return utf8.decode(value);
    return value.toString();
  }

  String? _amenitiesToDb(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).join(',');
    }
    if (value is String) return value;
    return value.toString();
  }

  Router get router {
    final router = Router();

    // GET ALL ROOMS
    router.get('/', (Request request) async {
      final conn = await Database.getConnection();
      try {
        final results = await conn.query('SELECT * FROM rooms');
        final rooms = results.map((row) => {
          'id': row['id'].toString(),
          'roomNumber': row['roomNumber'],
          'type': row['type'],
          'pricePerNight': row['pricePerNight'],
          'amenities': _dbValueToString(row['amenities'])?.split(','),
          'image': _dbValueToString(row['image']),
          'isAvailable': row['isAvailable'] == 1 || row['isAvailable'] == true,
          'totalRooms': row['totalRooms'],
        }).toList();

        return Response.ok(jsonEncode(rooms), headers: _jsonHeaders);
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: _jsonHeaders,
        );
      } finally {
        await conn.close();
      }
    });

    // ADD ROOM
    router.post('/', (Request request) async {
      final payload = jsonDecode(await request.readAsString());
      final conn = await Database.getConnection();
      try {
        await conn.query(
          'INSERT INTO rooms (roomNumber, type, pricePerNight, amenities, image, isAvailable, totalRooms) VALUES (?, ?, ?, ?, ?, ?, ?)',
          [
            payload['roomNumber'],
            payload['type'],
            payload['pricePerNight'],
            _amenitiesToDb(payload['amenities']),
            payload['image'],
            _boolToTinyInt(payload['isAvailable']) ?? 1,
            payload['totalRooms'],
          ],
        );
        return Response.ok(
          jsonEncode({'status': 'success', 'message': 'Room added'}),
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

    // UPDATE ROOM
    router.put('/<id>', (Request request, String id) async {
      final payload = jsonDecode(await request.readAsString());
      final conn = await Database.getConnection();
      try {
        final updates = <String, dynamic>{};

        if (payload.containsKey('roomNumber')) {
          updates['roomNumber'] = payload['roomNumber'];
        }
        if (payload.containsKey('type')) {
          updates['type'] = payload['type'];
        }
        if (payload.containsKey('pricePerNight')) {
          updates['pricePerNight'] = payload['pricePerNight'];
        }
        if (payload.containsKey('amenities')) {
          updates['amenities'] = _amenitiesToDb(payload['amenities']);
        }
        if (payload.containsKey('image')) {
          updates['image'] = payload['image'];
        }
        if (payload.containsKey('isAvailable')) {
          final v = _boolToTinyInt(payload['isAvailable']);
          if (v != null) updates['isAvailable'] = v;
        }
        if (payload.containsKey('totalRooms')) {
          updates['totalRooms'] = payload['totalRooms'];
        }

        if (updates.isEmpty) {
          return Response(
            400,
            body: jsonEncode({'status': 'error', 'message': 'No fields to update'}),
            headers: _jsonHeaders,
          );
        }

        final setSql = updates.keys.map((k) => '$k = ?').join(', ');
        final values = [...updates.values, id];

        await conn.query('UPDATE rooms SET $setSql WHERE id = ?', values);
        return Response.ok(
          jsonEncode({'status': 'success', 'message': 'Room updated'}),
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

    // DELETE ROOM
    router.delete('/<id>', (Request request, String id) async {
      final conn = await Database.getConnection();
      try {
        // Check for active bookings
        final bookings = await conn.query(
          'SELECT COUNT(*) as count FROM bookings WHERE roomId = ? AND status NOT IN ("cancelled", "completed") AND checkOut >= CURDATE()',
          [id],
        );

        if (bookings.first['count'] > 0) {
          return Response(
            400,
            body: jsonEncode({
              'status': 'error',
              'message': 'Cannot delete room with active or future bookings'
            }),
            headers: _jsonHeaders,
          );
        }

        await conn.query('DELETE FROM rooms WHERE id = ?', [id]);
        return Response.ok(
          jsonEncode({'status': 'success', 'message': 'Room deleted'}),
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
