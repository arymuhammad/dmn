class ActiveSubscriptionModel {
  final int id;
  final int userId;
  final int planId;
  final int? transactionId;
  final double amount;
  final String startedAt;
  final String expiresAt;
  final String status;
  final String name;
  final String? description;
  final double price;
  final double? promoPrice;
  final int duration;
  final String durationUnit;

  ActiveSubscriptionModel({
    required this.id,
    required this.userId,
    required this.planId,
    this.transactionId,
    required this.amount,
    required this.startedAt,
    required this.expiresAt,
    required this.status,
    required this.name,
    this.description,
    required this.price,
    this.promoPrice,
    required this.duration,
    required this.durationUnit,
  });

  factory ActiveSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return ActiveSubscriptionModel(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      planId: int.parse(json['plan_id'].toString()),
      transactionId:
          json['transaction_id'] == null
              ? null
              : int.parse(json['transaction_id'].toString()),
      amount: double.parse(json['amount'].toString()),
      startedAt: json['started_at'].toString(),
      expiresAt: json['expires_at'].toString(),
      status: json['status'].toString(),
      name: json['name'].toString(),
      description: json['description']?.toString(),
      price: double.parse(json['price'].toString()),
      promoPrice:
          json['promo_price'] == null
              ? null
              : double.parse(json['promo_price'].toString()),
      duration: int.parse(json['duration'].toString()),
      durationUnit: json['duration_unit'].toString(),
    );
  }
  String get durationText {
    if (durationUnit == 'day') {
      return '$duration Hari';
    }
    if (durationUnit == 'month') {
      return '$duration Bulan';
    }
    if (durationUnit == 'year') {
      return '$duration Tahun';
    }
    return '$duration $durationUnit';
  }
}
