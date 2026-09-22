import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/currency_locale.dart';
import '../../helpers/currency_service.dart';

class LanguageController extends GetxController {
  static const String _languageKey = 'app_language';

  final selectedLocale = const Locale('id', 'ID').obs;

  final CurrencyService currencyC = Get.find<CurrencyService>();

  final languages = <String, String>{
    'id_ID': 'Indonesia',
    'hi_IN': 'India',
    'en_US': 'English',
    'ja_JP': '日本語',
    'ko_KR': '한국어',
    'ms_MY': 'Malaysia',
  };

  @override
  void onInit() {
    super.onInit();

    loadLanguage();
  }

  // ============================================================
  // LOAD SAVED LANGUAGE
  // ============================================================

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    final languageCode = prefs.getString(_languageKey) ?? 'id_ID';

    final parts = languageCode.split('_');

    if (parts.length != 2) {
      await _applyLanguage('id_ID', save: false);
      return;
    }

    await _applyLanguage(languageCode, save: false);
  }

  // ============================================================
  // CHANGE LANGUAGE
  // ============================================================

  Future<void> changeLanguage(String languageCode) async {
    final parts = languageCode.split('_');

    if (parts.length != 2) return;

    final locale = Locale(parts[0], parts[1]);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_languageKey, languageCode);

    // ============================================================
    // UPDATE LANGUAGE
    // ============================================================

    selectedLocale.value = locale;

    await Get.updateLocale(locale);

    // ============================================================
    // UPDATE CURRENCY
    // ============================================================

    final currency = CurrencyLocale.getCurrency(languageCode);

    await currencyC.setCurrency(currency);

    debugPrint('[Language] $languageCode → $currency');
  }

  // ============================================================
  // APPLY LANGUAGE + CURRENCY
  // ============================================================

  Future<void> _applyLanguage(String languageCode, {required bool save}) async {
    final parts = languageCode.split('_');

    if (parts.length != 2) {
      return;
    }

    final locale = Locale(parts[0], parts[1]);

    // ------------------------------------------------------------
    // SAVE LANGUAGE
    // ------------------------------------------------------------

    if (save) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_languageKey, languageCode);
    }

    // ------------------------------------------------------------
    // UPDATE REACTIVE LOCALE
    // ------------------------------------------------------------

    selectedLocale.value = locale;

    // ------------------------------------------------------------
    // UPDATE GETX LOCALE
    // ------------------------------------------------------------

    if (Get.locale != locale) {
      await Get.updateLocale(locale);
    }

    // ------------------------------------------------------------
    // UPDATE CURRENCY
    // ------------------------------------------------------------

    final currency = CurrencyLocale.getCurrency(languageCode);

    await currencyC.setCurrency(currency);

    debugPrint('[Language] $languageCode');

    debugPrint('[Currency] $currency');

    debugPrint('[Rate] ${currencyC.exchangeRate.value}');
  }

  // ============================================================
  // GETTERS
  // ============================================================

  String get currentLanguageCode {
    final locale = selectedLocale.value;

    return '${locale.languageCode}_${locale.countryCode}';
  }

  String get currentLanguageName {
    return languages[currentLanguageCode] ?? 'Indonesia';
  }
}
