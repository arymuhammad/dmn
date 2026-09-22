import 'package:dio/dio.dart';

import '../helpers/exception.dart';
import 'storage_service.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.readToken();

          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }

          handler.next(options);
        },

        onResponse: (response, handler) {
          handler.next(response);
        },

        onError: (e, handler) {
          final statusCode = e.response?.statusCode;

          String message = 'Terjadi kesalahan.';

          final data = e.response?.data;

          if (data is Map && data['message'] != null) {
            message = data['message'].toString();
          } else if (e.message != null && e.message!.isNotEmpty) {
            message = e.message!;
          }

          handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: ApiException(message, statusCode: statusCode, data: data),
              message: message,
            ),
          );
        },
      ),
    );
  }

  Future<Response> get(String url) {
    return dio.get(url);
  }

  Future<Response> post(
    String url, {
    Map<String, dynamic>? body,
    Options? options,
  }) {
    return dio.post(
      url,
      data: body != null ? FormData.fromMap(body) : null,
      options: options,
    );
  }

  Future<Response> delete(String url) {
    return dio.delete(url);
  }
}
