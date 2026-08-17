import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/telemetry.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  ApiException(this.message, {this.statusCode, this.responseBody});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => 'NetworkException: $message';
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  String? _baseUrl;
  String? _userId;

  String get baseUrl => _baseUrl ?? AppConstants.apiBaseUrl;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('api_base_url') ?? AppConstants.apiBaseUrl;
    _userId = prefs.getString(AppConstants.userIdKey);
    
    if (_userId == null) {
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(AppConstants.userIdKey, _userId!);
    }
  }

  String get userId => _userId ?? 'unknown_user';

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', url);
  }

  Future<void> setUserId(String id) async {
    _userId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userIdKey, id);
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<http.Response> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = {..._getHeaders(), ...?headers};
    
    http.Response response;
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(url, headers: requestHeaders)
              .timeout(timeout ?? AppConstants.apiTimeout);
          break;
        case 'POST':
          response = await _client.post(
            url,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(timeout ?? AppConstants.apiTimeout);
          break;
        case 'PUT':
          response = await _client.put(
            url,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(timeout ?? AppConstants.apiTimeout);
          break;
        case 'DELETE':
          response = await _client.delete(url, headers: requestHeaders)
              .timeout(timeout ?? AppConstants.apiTimeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException || e is NetworkException) rethrow;
      throw ApiException('Request failed: $e');
    }

    return _handleResponse(response);
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    String message;
    try {
      final body = jsonDecode(response.body);
      message = body['detail'] ?? body['message'] ?? 'Server error';
    } catch (_) {
      message = 'Server error (${response.statusCode})';
    }

    throw ApiException(
      message,
      statusCode: response.statusCode,
      responseBody: response.body,
    );
  }

  Future<bool> healthCheck() async {
    try {
      final response = await _request('GET', AppConstants.healthEndpoint);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<IncidentResponse> sendTelemetry(TelemetryData telemetry) async {
    final response = await _request(
      'POST',
      AppConstants.telemetryEndpoint,
      body: telemetry.toJson(),
    );
    return IncidentResponse.fromJson(jsonDecode(response.body));
  }

  Future<List<dynamic>> getIncidents() async {
    final response = await _request('GET', AppConstants.incidentsEndpoint);
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> startJourney() async {
    final response = await _request(
      'POST',
      '/api/v1/journeys/start',
      body: {'user_id': userId},
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> stopJourney(String journeyId) async {
    final response = await _request(
      'POST',
      '/api/v1/journeys/$journeyId/stop',
      body: {'user_id': userId},
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> close() async {
    _client.close();
  }
}