import 'package:dio/dio.dart';
import '../config/env.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDio(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout =>
        ApiException('Connection timed out. The server did not respond in time.'),
      DioExceptionType.connectionError =>
        ApiException('No internet connection. Please check your network connectivity.'),
      DioExceptionType.badCertificate =>
        ApiException('Server security certificate is invalid or untrusted.'),
      DioExceptionType.cancel =>
        ApiException('The network request was cancelled.'),
      DioExceptionType.badResponse => _fromResponse(e.response),
      DioExceptionType.unknown => ApiException(
          'An unexpected error occurred: ${Env.samarkan(e.message ?? '-')}',
        ),
    };
  }

  /// GNews errors format: {"errors": ["message"]} or {"errors": {"param": "message"}}
  static ApiException _fromResponse(Response<dynamic>? response) {
    final code = response?.statusCode;
    final serverMessage = _extractServerMessage(response?.data);

    final message = switch (code) {
      400 => 'Invalid request.${serverMessage != null ? ' $serverMessage' : ''}',
      401 => 'API key is invalid or unregistered. Please check config/env.json.',
      403 => 'Daily request limit reached or account email is unverified.',
      404 => 'The requested endpoint was not found.',
      429 => 'Too many requests. GNews free tier allows at most 1 request per second.',
      final c? when c >= 500 => 'GNews server is temporarily unavailable ($c).',
      _ => 'Failed to load news (HTTP ${code ?? '-'}).',
    };

    return ApiException(message.trim(), statusCode: code);
  }

  static String? _extractServerMessage(dynamic data) {
    if (data is! Map) return null;
    final errors = data['errors'];
    if (errors is List && errors.isNotEmpty) return errors.first.toString();
    if (errors is Map && errors.isNotEmpty) return errors.values.first.toString();
    return null;
  }

  @override
  String toString() => message;
}
