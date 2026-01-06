import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:new_test_app/api.dart';
import 'package:new_test_app/constant.dart'; // Your Apis class

class AdminPendingUsersController extends GetxController {
  var pendingUsers = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isProcessing = false.obs;

  String get token => tokenUser ?? "";

  @override
  void onInit() {
    super.onInit();
    fetchPendingUsers();
  }

  // Fetch pending users: GET /api/admin/users/pending
  Future<void> fetchPendingUsers() async {
    try {
      isLoading.value = true;

      final response = await http.get(
        Uri.parse(Apis.adminPendingUsers), // Define in your Apis class
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        pendingUsers.assignAll(data.cast<Map<String, dynamic>>());
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar('خطأ', error['message'] ?? 'فشل تحميل الطلبات');
      }
    } catch (e) {
      Get.snackbar('خطأ في الاتصال', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Approve user: POST /api/admin/users/{id}/approve
  Future<void> approveUser(int userId) async {
    await _processAction(userId, 'approve', 'تمت الموافقة على الطلب بنجاح');
  }

  Future<void> rejectUser(int userId, String reason) async {
    if (reason.trim().isEmpty) {
      Get.snackbar(
        'مطلوب',
        'يرجى إدخال سبب الرفض',
        backgroundColor: Colors.red,
      );
      return;
    }
    await _processAction(userId, 'reject', 'تم رفض الطلب', reason: reason);
  }

  Future<void> _processAction(
    int userId,
    String action,
    String successMessage, {
    String? reason,
  }) async {
    try {
      isProcessing.value = true;

      final url = action == 'approve'
          ? Apis.adminApproveUser(userId)
          : Apis.adminRejectUser(userId);

      final Map<String, String> body = action == 'reject'
          ? {'reason': reason!}
          : {};

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('نجاح', successMessage, backgroundColor: Colors.green);
        // Remove user from list
        pendingUsers.removeWhere((user) => user['id'] == userId);
      } else {
        throw data['message'] ?? 'فشلت العملية';
      }
    } catch (e) {
      Get.snackbar('خطأ', e.toString(), backgroundColor: Colors.red);
    } finally {
      isProcessing.value = false;
    }
  }

  // Helper methods
  String getFullName(Map<String, dynamic> user) {
    return "${user['firstname']} ${user['lastname']}";
  }

  String getBirthDate(Map<String, dynamic> user) {
    final y = user['year_of_birth'];
    final m = user['month_of_birth'].toString().padLeft(2, '0');
    final d = user['day_of_birth'].toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String getProfileImageUrl(Map<String, dynamic> user) {
    if (user['image'] == null || user['image'].toString().isEmpty) return '';
    return '${Apis.baseUrl}/storage/${user['image']}';
  }
}
