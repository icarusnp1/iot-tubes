import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Check database connection
  /// Returns a Map with 'success' (bool) and 'message' (String)
  Future<Map<String, dynamic>> checkDatabaseConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.dbCheckUrl),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            ApiConfig.timeoutDuration,
            onTimeout: () {
              throw Exception('Connection timeout - Server tidak merespons');
            },
          );

      // Parse response
      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Success
        if (data['ok'] == true) {
          return {
            'success': true,
            'message': 'Database terhubung dengan baik',
            'data': data,
          };
        } else {
          return {
            'success': false,
            'message': 'Database tidak terhubung',
            'data': data,
          };
        }
      } else {
        // Server returned error
        return {
          'success': false,
          'message': data['error'] ?? 'Terjadi kesalahan pada server',
          'statusCode': response.statusCode,
        };
      }
    } on SocketException {
      // No internet or server not reachable
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server. Pastikan server berjalan dan IP address benar.',
      };
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Kesalahan koneksi HTTP',
      };
    } on FormatException {
      return {
        'success': false,
        'message': 'Format response tidak valid',
      };
    } catch (e) {
      // Other errors
      print('Error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Generic GET request method
  /// If [auth] is true, the method will attach the saved JWT from
  /// SharedPreferences as `Authorization: Bearer <token>` header.
  Future<Map<String, dynamic>> get(String endpoint, {bool auth = false}) async {
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};

      if (auth) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        } else {
          return {
            'success': false,
            'message': 'Token tidak ditemukan, silakan login',
            'statusCode': 401,
          };
        }
      }

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: headers,
          )
          .timeout(ApiConfig.timeoutDuration);

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'statusCode': response.statusCode,
        'data': json.decode(response.body),
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Generic POST request method
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(ApiConfig.timeoutDuration);

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'statusCode': response.statusCode,
        'data': json.decode(response.body),
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}