class CurrencyLocale {
  static String getCurrency(String languageCode) {
    switch (languageCode) {
      case 'id_ID':
        return 'IDR';

      case 'en_US':
        return 'USD';

      case 'ms_MY':
        return 'MYR';

      case 'ja_JP':
        return 'JPY';

      case 'ko_KR':
        return 'KRW';

      case 'hi_IN':
        return 'INR';

      default:
        return 'USD';
    }
  }

  static String getLocale(String languageCode) {
    switch (languageCode) {
      case 'id_ID':
        return 'id_ID';

      case 'en_US':
        return 'en_US';

      case 'ms_MY':
        return 'ms_MY';

      case 'ja_JP':
        return 'ja_JP';

      case 'ko_KR':
        return 'ko_KR';

      case 'hi_IN':
        return 'hi_IN';

      default:
        return 'en_US';
    }
  }
}