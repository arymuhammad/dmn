import 'package:dio/dio.dart';
import 'package:dmn_play/app/data/services/api_config.dart';
import 'api_client.dart';

class ServiceApi {
  ServiceApi._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.apiUrl,
      // baseUrl: "https://dmnplay.co.id/api/v1/",
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