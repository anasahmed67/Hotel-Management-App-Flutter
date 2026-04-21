import 'package:mysql1/mysql1.dart';
import 'dart:io';

class Database {
  static ConnectionSettings _settings() {
    final env = Platform.environment;
    
    // Log intent to connect
    print('DB: Attempting connection to ${env['DB_HOST'] ?? 'localhost'}:${env['DB_PORT'] ?? '3306'}...');

    return ConnectionSettings(
      host: env['DB_HOST'] ?? 'localhost',
      port: int.tryParse(env['DB_PORT'] ?? '') ?? 3306,
      user: env['DB_USER'] ?? 'root',
      password: env['DB_PASSWORD'],
      db: env['DB_NAME'] ?? 'hotel_booking_db',
      timeout: const Duration(seconds: 5), // Added 5s timeout
    );
  }

  static Future<MySqlConnection> getConnection() async {
    try {
      final conn = await MySqlConnection.connect(_settings());
      print('DB: Success! Connection established.');
      return conn;
    } catch (e) {
      print('DB: CRITICAL ERROR - Failed to connect: $e');
      rethrow;
    }
  }
}

