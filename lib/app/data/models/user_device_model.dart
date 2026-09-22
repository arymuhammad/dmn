class UserDeviceModel {
  final int id;
  final String userID;
  final String fcmToken;
  final String platform;
  final String deviceName;

  UserDeviceModel({
    required this.id,
    required this.userID,
    required this.fcmToken,
    required this.platform,
    required this.deviceName,
  });

  factory UserDeviceModel.fromJson(Map<String, dynamic> json) {
    return UserDeviceModel(
      id: int.parse(json["id"].toString()),
      userID: json["user_id"] ?? "",
      fcmToken: json["fcm_token"] ?? "",
      platform: json["platform"] ?? "",
      deviceName: json["device_name"] ?? "",
    );
  }
}
