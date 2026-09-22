import 'package:dmn_play/app/data/models/user_device_model.dart';

class UserModel {
  final int id;
  final String fullname;
  final String email;
  final String avatar;
  final bool isVip;
  final List<UserDeviceModel> userDevices;

  UserModel({
    required this.id,
    required this.fullname,
    required this.email,
    required this.avatar,
    required this.isVip,
    this.userDevices = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userDevices =
        (json["devices"] as List? ?? [])
            .map((e) => UserDeviceModel.fromJson(e))
            .toList();

    return UserModel(
      id: int.parse(json["id"].toString()),
      fullname: json["fullname"] ?? "",
      email: json["email"] ?? "",
      avatar: json["avatar"] ?? "",
      isVip: json["is_vip"].toString() == "1",
      userDevices: userDevices,
    );
  }
}
