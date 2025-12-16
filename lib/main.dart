import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:new_test_app/features/auth/pages/login_page.dart';
import 'package:new_test_app/features/auth/pages/register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'تطبيق إدارة الشقق',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: LoginPage(),

      // FIX: Use 'ar' instead of 'ar_SA'
      locale: const Locale('ar'), // ← Changed from Locale('ar', 'SA')

      supportedLocales: const [
        Locale('ar'), // Arabic (generic)
        Locale('en', 'US'), // English
      ],

      // ADD: Required localization delegates
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Optional: Better navigation routes
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
      ],

      defaultTransition: Transition.rightToLeft,
    );
  }
}
