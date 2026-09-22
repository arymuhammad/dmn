import 'package:dmn_play/app/modules/navbar/views/navbar_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/bindings/initial_binding.dart';
import 'app/data/translations/app_translations.dart';
import 'app/routes/app_pages.dart';
import 'package:media_kit/media_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MediaKit.ensureInitialized();

  await Firebase.initializeApp();

  // Initialize Indonesian locale for DateFormat
  await initializeDateFormatting('id_ID', null);

  final prefs = await SharedPreferences.getInstance();

  final language = prefs.getString('app_language');

  Locale locale = const Locale('id', 'ID');

  if (language != null) {
    final parts = language.split('_');

    if (parts.length == 2) {
      locale = Locale(parts[0], parts[1]);
    }
  }

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false),
      translations: AppTranslations(),
      locale: locale,
      fallbackLocale: const Locale('en', 'US'),
      home: NavbarView(),
      initialBinding: InitialBinding(),
      // initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
