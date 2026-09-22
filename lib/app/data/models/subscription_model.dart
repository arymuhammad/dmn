import 'package:get/get.dart';

class SubscriptionModel {
  final int id;
  final String name;
  final double price;
  final double? promoPrice;
  final String? promoEndsAt;
  final int duration;
  final String durationUnit;
  final String description;

  SubscriptionModel({
    required this.id,
    required this.name,
    required this.price,
    this.promoPrice,
    this.promoEndsAt,
    required this.duration,
    required this.durationUnit,
    required this.description,
  });

  // ============================================================
  // PROMO AKTIF
  // ============================================================

  bool get isPromo {
    // Tidak ada promo price
    if (promoPrice == null) {
      return false;
    }

    // Promo harus lebih murah dari harga normal
    if (promoPrice! >= price) {
      return false;
    }

    // Tidak ada tanggal promo
    if (promoEndsAt == null || promoEndsAt!.trim().isEmpty) {
      return false;
    }

    final endDate = DateTime.tryParse(promoEndsAt!.trim());

    // Tanggal tidak valid
    if (endDate == null) {
      return false;
    }

    // Promo aktif sampai tanggal/waktu yang ditentukan
    return DateTime.now().isBefore(endDate);
  }

  // ============================================================
  // HARGA AKTIF
  // ============================================================

  double get finalPrice {
    return isPromo ? promoPrice! : price;
  }

  // ============================================================
  // DURASI
  // ============================================================

  String get durationText {
    return '$duration ${durationUnit.tr}';
  }

  // ============================================================
  // JSON
  // ============================================================

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final model = SubscriptionModel(
      id: int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      price: double.parse(json['price'].toString()),
      promoPrice:
          json['promo_price'] != null
              ? double.parse(json['promo_price'].toString())
              : null,
      promoEndsAt: json['promo_ends_at']?.toString(),
      duration: int.parse(json['duration'].toString()),
      durationUnit: json['duration_unit']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );

    // DEBUG
    print(
      '[SUBSCRIPTION] '
      '${model.name} | '
      'price=${model.price} | '
      'promo=${model.promoPrice} | '
      'promoEndsAt=${model.promoEndsAt} | '
      'isPromo=${model.isPromo}',
    );

    return model;
  }
}
