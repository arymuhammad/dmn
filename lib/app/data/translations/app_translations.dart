import 'locales/hi_IN.dart';
import 'package:get/get.dart';

import 'locales/en_us.dart';
import 'locales/id_id.dart';
import 'locales/ja_JP.dart';
import 'locales/ko_KR.dart';
import 'locales/ms_MY.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'hi_IN': hiIN,
        'id_ID': idID,
        'ja_JP': jaJP,
        'ko_KR': koKR,
        'ms_MY': msMY,
        // 'ja_JP': jaJP,
        // 'ko_KR': koKR,
      };
}