import 'package:mysql1/mysql1.dart';
import 'dart:io';

class Database {
  static ConnectionSettings _settings() {
    final env = Platform.environment;

    return ConnectionSettings(
      host: env['DB_HOST'] ?? 'localhost',
      port: int.tryParse(env['DB_PORT'] ?? '') ?? 3306,
      user: env['DB_USER'] ?? 'root',
      password: env['DB_PASSWORD'],
      db: env['DB_NAME'] ?? 'hotel_booking_db',
    );
  }

  static Future<MySqlConnection> getConnection() async {
    return await MySqlConnection.connect(_settings());
  }
}
