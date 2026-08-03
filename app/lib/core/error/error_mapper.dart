import 'package:dio/dio.dart';
import 'package:qwe1/core/error/app_exception.dart';

class ErrorMapper {
  static AppException fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Connection timed out. Please check your network.');
      case DioExceptionType.connectionError:
        return const NetworkException('Could not connect to server. Is the agent running?');
      case DioExceptionType.badResponse:
        return _fromStatusCode(e.response?.statusCode, e.response?.data);
      case DioExceptionType.cancel:
        return const NetworkException('Request was cancelled.');
      case DioExceptionType.unknown:
        return NetworkException('An unexpected error occurred: ${e.message}');
      case DioExceptionType.badCertificate:
        return const NetworkException('Certificate verification failed.');
      default:
        return const NetworkException('An unexpected error occurred.');
    }
  }

  static AppException fromWebSocketException(Object error) {
    return NetworkException('WebSocket error: $error');
  }

  static AppException _fromStatusCode(int? statusCode, dynamic data) {
    String? message;
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        message = error['message'] as String?;
      }
    }

    if (statusCode == null) {
      return const NetworkException('Server returned unknown error.');
    }

    switch (statusCode) {
      case 400:
        return ValidationException(message ?? 'Invalid request.');
      case 401:
        final code = data is Map<String, dynamic>
            ? (data['error'] is Map ? (data['error'] as Map)['code'] : null)
            : null;
        if (code == 'INVALID_ENROLLMENT') {
          return const AuthException(
            'Invalid or already-used enrollment token. Generate a new one with token.sh.',
          );
        }
        return const AuthException('Authentication required. Please re-enroll.');
      case 403:
        return const AuthException('Access denied. Check server permissions.');
      case 404:
        return const ServerNotFoundException('Resource not found.');
      case 409:
        return const ContainerException('Conflict: resource is already in the target state.');
      case 413:
        return const ValidationException('Payload too large.');
      case 426:
        return const ValidationException('API version mismatch. Please update the app or agent.');
      case 429:
        int? retryAfter;
        if (data is Map<String, dynamic>) {
          retryAfter = data['retryAfter'] as int?;
        }
        return RateLimitException(
          'Rate limited. ${retryAfter != null ? "Retry after ${retryAfter}s." : "Please try again later."}',
        );
      case 500:
        return const NetworkException('Internal server error.');
      case 503:
        return const ServerUnavailableException('Service unavailable. Docker socket may be down.');
      default:
        return NetworkException('Server returned $statusCode error.');
    }
  }
}
