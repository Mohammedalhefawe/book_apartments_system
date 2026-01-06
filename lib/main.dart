// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:new_test_app/features/auth/pages/login_page.dart';
import 'package:new_test_app/features/auth/pages/register_page.dart';
import 'package:new_test_app/features/settings/controllers/settings_controller.dart';
import 'package:new_test_app/translations/app_translations.dart';

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.put(SettingsController());

    return Obx(
      () => GetMaterialApp(
        title: 'تطبيق إدارة الشقق',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: settingsController.themeMode.value,
        translations: AppTranslations(), // ← Your translations
        locale: settingsController.currentLocale.value,
        supportedLocales: const [Locale('ar'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        home: LoginPage(),
        getPages: [
          GetPage(name: '/login', page: () => LoginPage()),
          GetPage(name: '/register', page: () => RegisterPage()),
        ],

        defaultTransition:
            settingsController.currentLocale.value.languageCode == 'ar'
            ? Transition.rightToLeft
            : Transition.leftToRight,
      ),
    );
  }
}
