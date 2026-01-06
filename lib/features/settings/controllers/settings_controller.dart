// controllers/settings_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final box = GetStorage();

  // Keys
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';

  // Theme
  var themeMode = ThemeMode.system.obs;

  // Language
  var currentLocale = const Locale('ar').obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    // Load theme
    String? savedTheme = box.read(_themeKey);
    if (savedTheme != null) {
      for (var mode in ThemeMode.values) {
        if (mode.toString() == savedTheme) {
          themeMode.value = mode;
          break;
        }
      }
    }

    // Load language
    String? savedLang = box.read(_languageKey);
    if (savedLang != null) {
      currentLocale.value = Locale(savedLang);
    } else {
      currentLocale.value = const Locale('ar');
    }
  }

  Future<void> changeTheme(ThemeMode mode) async {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    await box.write(_themeKey, mode.toString());
  }

  Future<void> changeLanguage(String languageCode) async {
    currentLocale.value = Locale(languageCode);
    Get.updateLocale(Locale(languageCode));
    await box.write(_languageKey, languageCode);
  }

  String get currentLanguageName {
    return currentLocale.value.languageCode == 'ar' ? 'العربية' : 'English';
  }

  String getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light'.tr;
      case ThemeMode.dark:
        return 'dark'.tr;
      case ThemeMode.system:
        return 'system'.tr;
    }
  }

  // Helper method to get language display name
  String getLanguageDisplayName(String code) {
    return code == 'ar' ? 'العربية' : 'English';
  }
}
