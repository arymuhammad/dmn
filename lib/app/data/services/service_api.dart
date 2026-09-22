import 'package:dio/dio.dart';
import 'api_client.dart';

class ServiceApi {
  ServiceApi._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://103.156.15.61/dmn/api/v1/",
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      // responseType: ResponseType.plain,
      headers: {
        "Accept": "application/json",
      },
    ),
  );

  static final ApiClient client = ApiClient(dio);
}