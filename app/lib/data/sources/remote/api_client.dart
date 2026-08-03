import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:qwe1/core/error/error_mapper.dart';

class ApiClient {
  ApiClient({
    required this.baseUrl,
    this.onRefreshToken,
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'X-Api-Version': '1',
      },
    ));

    _dio.interceptors.add(AuthInterceptor(
      dio: _dio,
      onRefreshToken: onRefreshToken,
    ));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  late final Dio _dio;
  final String baseUrl;

  /// Invoked by the auth interceptor on a 401 response to obtain a fresh
  /// access token (e.g. via POST /auth/refresh). Returns null if refresh fails.
  final Future<String?> Function()? onRefreshToken;

  void setAccessToken(String? token) {
    final value = token != null ? 'Bearer $token' : null;
    debugPrint('[api] setAccessToken: ${token != null ? "Bearer <${token.length} chars>" : null}');
    _dio.options.headers['Authorization'] = value;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDioException(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDioException(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDioException(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDioException(e);
    }
  }
}

/// Adds the Bearer token and transparently refreshes the access token once
/// when the server answers 401 (expired/invalid token).
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    this.onRefreshToken,
  }) : _dio = dio;

  final Dio _dio;
  final Future<String?> Function()? onRefreshToken;

  static const _retriedKey = '__qwe_retried';

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && onRefreshToken != null) {
      final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;
      if (!alreadyRetried) {
        try {
          debugPrint('[api] 401 received — attempting token refresh');
          final newToken = await onRefreshToken!();
          if (newToken != null) {
            debugPrint('[api] refresh succeeded — retrying request');
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newToken';
            opts.extra[_retriedKey] = true;
            final response = await _dio.fetch(opts);
            handler.resolve(response);
            return;
          }
          debugPrint('[api] refresh failed — forwarding 401');
        } catch (_) {
          debugPrint('[api] refresh threw — forwarding 401');
        }
      }
    }
    handler.next(err);
  }
}
