import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CurrencyService extends GetxService {
  static const String _baseCurrency = 'IDR';

  final RxString currentCurrency = _baseCurrency.obs;
  final RxDouble exchangeRate = 1.0.obs;

  final RxBool isLoading = false.obs;
  final RxString lastUpdated = ''.obs;

  Future<CurrencyService> init() async {
    await setCurrency('IDR');
    return this;
  }

  Future<void> setCurrency(String currency) async {
    currency = currency.toUpperCase();

    // ============================================================
    // IDR
    // ============================================================

    if (currency == _baseCurrency) {
      currentCurrency.value = _baseCurrency;
      exchangeRate.value = 1.0;
      lastUpdated.value = '';
      isLoading.value = false;

      debugPrint('[Currency] $_baseCurrency → IDR = 1.0');

      return;
    }

    // ============================================================
    // CURRENCY SUDAH AKTIF
    // ============================================================

    if (currentCurrency.value == currency && exchangeRate.value != 1.0) {
      debugPrint(
        '[Currency] Already active: $_baseCurrency → $currency = ${exchangeRate.value}',
      );

      return;
    }

    isLoading.value = true;

    try {
      final url = Uri.parse(
        'https://api.frankfurter.dev/v2/rate/$_baseCurrency/$currency',
      );

      debugPrint('[Currency] Request: $url');

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Frankfurter error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      final rate = (data['rate'] as num).toDouble();

      // ==========================================================
      // SIMPAN RATE
      // ==========================================================

      currentCurrency.value = currency;
      exchangeRate.value = rate;
      lastUpdated.value = data['date']?.toString() ?? '';

      debugPrint('[Currency] $_baseCurrency → $currency = $rate');
    } catch (e) {
      debugPrint('[Currency] Error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ==============================================================
  // CONVERT IDR → CURRENT CURRENCY
  // ==============================================================

  double convert(double idrAmount) {
    if (currentCurrency.value == _baseCurrency) {
      return idrAmount;
    }

    return idrAmount * exchangeRate.value;
  }

  // ==============================================================
  // FORMAT PRICE
  // ==============================================================

  String format(double idrAmount, {String? currency, String? locale}) {
    final targetCurrency = (currency ?? currentCurrency.value).toUpperCase();

    final convertedAmount = convert(idrAmount);

    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '',
      decimalDigits: _decimalDigits(targetCurrency),
    );

    final amount = formatter.format(convertedAmount).trim();

    return '$targetCurrency $amount';
  }

  int _decimalDigits(String currency) {
    switch (currency) {
      case 'IDR':
      case 'JPY':
      case 'KRW':
        return 0;

      default:
        return 2;
    }
  }
}
