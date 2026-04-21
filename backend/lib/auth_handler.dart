import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'database.dart';

class AuthHandler {
  static const _jsonHeaders = {'content-type': 'application/json'};

  Router get router {
    final router = Router();

    // REGISTER
    router.post('/register', (Request request) async {
      final payload = jsonDecode(await request.readAsString());
      final conn = await Database.getConnection();

      try {
        final result = await conn.query(
          'INSERT INTO users (name, email, password, role, phone) VALUES (?, ?, ?, ?, ?)',
          [payload['name'], payload['email'], payload['password'], payload['role'] ?? 'customer', payload['phone'] ?? ''],
        );

        return Response.ok(
          jsonEncode({
            'status': 'success',
            'message': 'User registered successfully',
            'userId': result.insertId
          }),
          headers: _jsonHeaders,
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'status': 'error', 'message': e.toString()}),
          headers: _jsonHeaders,
        );
      } finally {
        await conn.close();
      }
    });

    // LOGIN
    router.post('/login', (Request request) async {
      final payload = jsonDecode(await request.readAsString());
      final conn = await Database.getConnection();

      try {
        final results = await conn.query(
          'SELECT * FROM users WHERE email = ? AND password = ?',
          [payload['email'], payload['password']],
        );

        if (results.isNotEmpty) {
          final user = results.first;
          return Response.ok(
            jsonEncode({
              'status': 'success',
              'message': 'Login successful',
              'user': {
                'id': user['id'],
                'name': user['name'],
                'email': user['email'],
                'role': user['role'],
                'phone': user['phone'] ?? ''
              }
            }),
            headers: _jsonHeaders,
          );
        } else {
          return Response.forbidden(
            jsonEncode({'status': 'error', 'message': 'Invalid email or password'}),
            headers: _jsonHeaders,
          );
        }
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'status': 'error', 'message': e.toString()}),
          headers: _jsonHeaders,
        );
      } finally {
        await conn.close();
      }
    });

    // UPDATE PROFILE
    router.post('/update-profile', (Request request) async {
      final payload = jsonDecode(await request.readAsString());
      final conn = await Database.getConnection();

      try {
        await conn.query(
          'UPDATE users SET name = ?, phone = ? WHERE email = ?',
          [payload['name'], payload['phone'], payload['email']],
        );

        return Response.ok(
          jsonEncode({'status': 'success', 'message': 'Profile updated'}),
          headers: _jsonHeaders,
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'status': 'error', 'message': e.toString()}),
          headers: _jsonHeaders,
        );
      } finally {
        await conn.close();
      }
    });

    // CHANGE PASSWORD
    router.post('/change-password', (Request request) async {
      final payload = jsonDecode(await request.readAsString());
      final conn = await Database.getConnection();

      try {
        await conn.query(
          'UPDATE users SET password = ? WHERE email = ?',
          [payload['password'], payload['email']],
        );

        return Response.ok(
          jsonEncode({'status': 'success', 'message': 'Password updated'}),
          headers: _jsonHeaders,
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'status': 'error', 'message': e.toString()}),
          headers: _jsonHeaders,
        );
      } finally {
        await conn.close();
      }
    });

    return router;
  }
}
