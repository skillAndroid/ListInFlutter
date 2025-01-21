import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/services/auth_service.dart';
class HttpService {
  final http.Client client;
  final AuthService authService;
  final String baseUrl;

  HttpService({
    required this.client,
    required this.authService,
    required this.baseUrl,
  });

  Future<T> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    try {
      // Get fresh token for each request
      final headers = requiresAuth 
          ? await _getAuthenticatedHeaders()
          : _getBaseHeaders();

      final uri = _buildUri(path, queryParameters);
      
      final response = await client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      // if (response.statusCode == 500 && requiresAuth) {
      //   // If we get 500 with auth, try refreshing token
      //   final newHeaders = await _refreshAndGetHeaders();
      //   final retryResponse = await client
      //       .get(uri, headers: newHeaders)
      //       .timeout(const Duration(seconds: 10));
            
      //   return _handleResponse<T>(retryResponse, fromJson);
      // }

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<T>> getList<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    try {
      final headers = requiresAuth 
          ? await _getAuthenticatedHeaders()
          : _getBaseHeaders();

      final uri = _buildUri(path, queryParameters);
      
      final response = await client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      // if (response.statusCode == 500 && requiresAuth) {
      //   // If we get 500 with auth, try refreshing token
      //   final newHeaders = await _refreshAndGetHeaders();
      //   final retryResponse = await client
      //       .get(uri, headers: newHeaders)
      //       .timeout(const Duration(seconds: 10));
            
      //   return _handleListResponse<T>(retryResponse, fromJson);
      // }

      return _handleListResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Map<String, String> _getBaseHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Connection': 'keep-alive',
    };
  }

  Future<Map<String, String>> _getAuthenticatedHeaders() async {
    final authOptions = await authService.getAuthOptions();
    final token = authOptions.headers?['Authorization'];
    
    if (token == null || token.isEmpty) {
      throw UnauthorizedException('No valid auth token found');
    }

    return {
      ..._getBaseHeaders(),
      'Authorization': token,
    };
  }

  // Future<Map<String, String>> _refreshAndGetHeaders() async {
  //   // Assuming you have a refresh token mechanism in AuthService
  //   await authService.();
  //   return _getAuthenticatedHeaders();
  // }

  Uri _buildUri(String path, Map<String, dynamic>? queryParameters) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    
    final queryParams = queryParameters?.map(
      (key, value) => MapEntry(
        key,
        value?.toString() ?? '',
      ),
    );

    return Uri.parse('$baseUrl/$normalizedPath')
        .replace(queryParameters: queryParams);
  }

  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        return fromJson(jsonResponse);
      } catch (e) {
        throw BadRequestExeption(message: 'Invalid response format: ${response.body}');
      }
    }

    // Handle specific error cases
    switch (response.statusCode) {
      case 400:
        throw BadRequestExeption(message: 'Bad request: ${response.body}');
      case 401:
        throw UnauthorizedException('Authentication failed');
      case 403:
        throw UnauthorizedException('Access forbidden');
      case 404:
        throw NotFoundExeption();
      case 500:
        final errorBody = json.decode(response.body);
        throw ServerExeption(
          message: errorBody['message'] ?? 'Server error occurred',
        );
      default:
        throw BadRequestExeption(
          message: 'Request failed with status: ${response.statusCode}',
        );
    }
  }

  List<T> _handleListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final content = jsonResponse['content'] as List<dynamic>;
        return content
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw BadRequestExeption(
          message: 'Invalid response format: ${response.body}',
        );
      }
    }

    // Reuse the same error handling logic
    throw _handleResponse(response, (json) => json);
  }

  Exception _handleError(Object e) {
    if (e is UnauthorizedException) {
      return e;
    } else if (e is http.ClientException) {
      return ConnectionExeption(message: 'Connection failed: ${e.message}');
    } else if (e is TimeoutException) {
      return ConnectiontTimeOutExeption();
    }
    return UknownExeption();
  }
}
