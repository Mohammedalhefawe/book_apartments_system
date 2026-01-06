// pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_test_app/features/auth/pages/login_page.dart';
import 'package:new_test_app/features/notifications/pages/notifications_page.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'settings'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Section
          Card(
            child: ListTile(
              leading: const Icon(Icons.language, color: Colors.blue),
              title: Text(
                'language'.tr,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Obx(() => Text(controller.currentLanguageName)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.bottomSheet(
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? Colors.grey[900] : Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'choose_language'.tr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildLanguageOption('ar', 'arabic'.tr, controller),
                        _buildLanguageOption('en', 'english'.tr, controller),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Theme Section
          Card(
            child: ListTile(
              leading: const Icon(Icons.brightness_6, color: Colors.orange),
              title: Text(
                'theme'.tr,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Obx(
                () => Text(controller.getThemeName(controller.themeMode.value)),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.bottomSheet(
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? Colors.grey[900] : Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'choose_theme'.tr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildThemeOption(
                          ThemeMode.light,
                          'light'.tr,
                          controller,
                        ),
                        _buildThemeOption(
                          ThemeMode.dark,
                          'dark'.tr,
                          controller,
                        ),
                        _buildThemeOption(
                          ThemeMode.system,
                          'system'.tr,
                          controller,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Theme Section
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.teal),
              title: Text(
                'notifications'.tr,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),

              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.to(() => NotificationsPage());
              },
            ),
          ),
          const SizedBox(height: 16),

          // logout Section
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                'logout'.tr,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              // subtitle: Text(''),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.offAll(LoginPage());
              },
            ),
          ),

          const SizedBox(height: 30),

          // App Info
          Center(
            child: Column(
              children: [
                Text(
                  'app_title'.tr,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${'version'.tr} 1.0.0',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    String code,
    String name,
    SettingsController controller,
  ) {
    return Obx(
      () => RadioListTile<String>(
        title: Text(name),
        value: code,
        groupValue: controller.currentLocale.value.languageCode,
        onChanged: (value) {
          if (value != null) {
            controller.changeLanguage(value);
            Get.back();
          }
        },
      ),
    );
  }

  Widget _buildThemeOption(
    ThemeMode mode,
    String name,
    SettingsController controller,
  ) {
    return Obx(
      () => RadioListTile<ThemeMode>(
        title: Text(name),
        value: mode,
        groupValue: controller.themeMode.value,
        onChanged: (value) {
          if (value != null) {
            controller.changeTheme(value);
            Get.back();
          }
        },
      ),
    );
  }
}
