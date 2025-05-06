import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../utils/config.dart';

enum HttpMethod { get, post, put, patch, delete }

class ApiResponse<T> {
  final T? data;
  final String? error;
  final int statusCode;

  ApiResponse({this.data, this.error, required this.statusCode});

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500;
  bool get isUnauthorized => statusCode == 401;
}

class ApiService {
  final http.Client _client;
  final AuthService _authService;
  final String baseUrl;

  ApiService({
    required this.baseUrl,
    required AuthService authService,
    http.Client? client,
  }) : _client = client ?? http.Client(),
       _authService = authService;

  Future<ApiResponse<T>> request<T>({
    required String endpoint,
    required HttpMethod method,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool requireAuth = true,
    required T Function(dynamic json) decoder,
  }) async {
    try {
      // Build URI with query parameters if provided
      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParams);

      // Build request headers
      final headers = {'Content-Type': 'application/json'};

      // Add auth token if required
      if (requireAuth) {
        final authHeaders = await _authService.getAuthHeaders();
        headers.addAll(authHeaders);
      }

      // Convert body to JSON if provided
      final jsonBody = body != null ? jsonEncode(body) : null;

      // Make the request
      http.Response response;

      switch (method) {
        case HttpMethod.get:
          response = await _client.get(uri, headers: headers);
          break;
        case HttpMethod.post:
          response = await _client.post(uri, headers: headers, body: jsonBody);
          break;
        case HttpMethod.put:
          response = await _client.put(uri, headers: headers, body: jsonBody);
          break;
        case HttpMethod.patch:
          response = await _client.patch(uri, headers: headers, body: jsonBody);
          break;
        case HttpMethod.delete:
          response = await _client.delete(uri, headers: headers);
          break;
      }

      // Handle response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success
        if (response.body.isEmpty) {
          return ApiResponse(data: null, statusCode: response.statusCode);
        }

        final jsonResponse = jsonDecode(response.body);
        return ApiResponse(
          data: decoder(jsonResponse),
          statusCode: response.statusCode,
        );
      } else {
        // Error
        String errorMessage;
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage =
              errorJson['message'] ??
              errorJson['error'] ??
              'Unknown error occurred';
        } catch (e) {
          errorMessage =
              response.body.isNotEmpty
                  ? response.body
                  : 'Error ${response.statusCode}';
        }

        // Handle 401 (Unauthorized) - token might be expired
        if (response.statusCode == 401 && requireAuth) {
          // Try to refresh token
          final refreshed = await _authService.refreshToken();
          if (refreshed) {
            // Retry the request with new token
            return request(
              endpoint: endpoint,
              method: method,
              body: body,
              queryParams: queryParams,
              requireAuth: requireAuth,
              decoder: decoder,
            );
          }
        }

        return ApiResponse(
          error: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse(error: 'No internet connection', statusCode: 0);
    } on FormatException {
      return ApiResponse(error: 'Invalid response format', statusCode: 0);
    } catch (e) {
      return ApiResponse(
        error: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Convenience methods
  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    Map<String, String>? queryParams,
    bool requireAuth = true,
    required T Function(dynamic json) decoder,
  }) => request<T>(
    endpoint: endpoint,
    method: HttpMethod.get,
    queryParams: queryParams,
    requireAuth: requireAuth,
    decoder: decoder,
  );

  Future<ApiResponse<T>> post<T>({
    required String endpoint,
    Map<String, dynamic>? body,
    bool requireAuth = true,
    required T Function(dynamic json) decoder,
  }) => request<T>(
    endpoint: endpoint,
    method: HttpMethod.post,
    body: body,
    requireAuth: requireAuth,
    decoder: decoder,
  );

  Future<ApiResponse<T>> put<T>({
    required String endpoint,
    Map<String, dynamic>? body,
    bool requireAuth = true,
    required T Function(dynamic json) decoder,
  }) => request<T>(
    endpoint: endpoint,
    method: HttpMethod.put,
    body: body,
    requireAuth: requireAuth,
    decoder: decoder,
  );

  Future<ApiResponse<T>> delete<T>({
    required String endpoint,
    bool requireAuth = true,
    required T Function(dynamic json) decoder,
  }) => request<T>(
    endpoint: endpoint,
    method: HttpMethod.delete,
    requireAuth: requireAuth,
    decoder: decoder,
  );
}
