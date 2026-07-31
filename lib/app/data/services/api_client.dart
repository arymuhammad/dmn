import 'package:dio/dio.dart';

class ApiClient {

  static final Dio dio = Dio(

    BaseOptions(

      baseUrl: "http://103.156.15.61/dmn/api/",

      connectTimeout: const Duration(seconds: 20),

      receiveTimeout: const Duration(seconds: 20),

      headers: {

        "Accept":"application/json"

      }

    )

  );

}