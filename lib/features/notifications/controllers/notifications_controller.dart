// controllers/notifications_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:new_test_app/api.dart';
import 'package:new_test_app/constant.dart';

class NotificationsController extends GetxController {
  var isLoading = true.obs;
  var unreadCount = 0.obs;
  var notifications = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse(Apis.notifications),
        headers: {
          'Authorization': 'Bearer $tokenUser',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['status'] == 1) {
          unreadCount.value = json['unread_count'] ?? 0;
          final List<dynamic> rawNotifications = json['notifications'];

          notifications.assignAll(
            rawNotifications.map((notif) {
              final data = notif['data'];
              final String type = data['type'] ?? '';
              String title = data['message'] ?? 'إشعار جديد';
              IconData icon;
              Color color;

              switch (type) {
                case 'booking_approved':
                  icon = Icons.check_circle_rounded;
                  color = Colors.green;
                  break;
                case 'booking_rejected':
                  icon = Icons.cancel_rounded;
                  color = Colors.red;
                  break;
                default:
                  icon = Icons.notifications_rounded;
                  color = Colors.blue;
              }

              return {
                'id': notif['id'],
                'title': title,
                'body': data['message'],
                'type': type,
                'icon': icon,
                'color': color,
                'time_ago': notif['created_at'],
                'is_read': notif['read_at'] != null,
              };
            }).toList(),
          );
        }
      } else {
        Get.snackbar('خطأ', 'فشل جلب الإشعارات');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل الاتصال: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    await fetchNotifications();
  }

  // Optional: Mark as read (if API supports it)
  // Future<void> markAsRead(String notificationId) async { ... }
}
