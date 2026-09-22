class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

class AccountSuspendedException implements Exception {
  final String message;
  final String reason;

  AccountSuspendedException({
    this.message = 'Akun Anda telah ditangguhkan.',
    this.reason = '',
  });

  @override
  String toString() => message;
}

class DeviceLimitException implements Exception {
  final String message;
  final int maxDevices;
  final List<Map<String, dynamic>> devices;

  DeviceLimitException({
    required this.message,
    required this.maxDevices,
    required this.devices,
  });

  @override
  String toString() => message;
}
