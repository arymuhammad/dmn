import 'api_client.dart';

class HomeService {
  Future getHome() async {
    final res = await ApiClient.dio.get("home");

    return res.data;
  }
}
