import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:new_test_app/api.dart';
import 'package:new_test_app/constant.dart';

class AdminPendingApartmentsController extends GetxController {
  var pendingApartments = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isProcessing = false.obs;

  String get token {
    return tokenUser ?? "";
  }

  @override
  void onInit() {
    super.onInit();
    fetchPendingApartments();
  }

  Future<void> fetchPendingApartments() async {
    try {
      isLoading.value = true;

      final response = await http.get(
        Uri.parse(Apis.adminPendingApartments),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        pendingApartments.assignAll(data.cast<Map<String, dynamic>>());
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar('خطأ', error['message'] ?? 'فشل تحميل الشقق المعلقة');
      }
    } catch (e) {
      Get.snackbar('خطأ في الاتصال', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveApartment(int apartmentId) async {
    await _processAction(
      apartmentId,
      'approve',
      'تمت الموافقة على الشقة بنجاح',
    );
  }

  Future<void> rejectApartment(int apartmentId, String reason) async {
    if (reason.trim().isEmpty) {
      Get.snackbar(
        'مطلوب',
        'يرجى كتابة سبب الرفض',
        backgroundColor: Colors.red,
      );
      return;
    }
    await _processAction(apartmentId, 'reject', 'تم رفض الشقة', reason: reason);
  }

  Future<void> _processAction(
    int apartmentId,
    String action,
    String successMessage, {
    String? reason,
  }) async {
    try {
      isProcessing.value = true;

      final url = action == 'approve'
          ? Apis.adminApproveApartment(apartmentId)
          : Apis.adminRejectApartment(apartmentId);

      final Map<String, dynamic> body = action == 'reject'
          ? {'reason': reason}
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
        // Remove from list
        pendingApartments.removeWhere((apt) => apt['id'] == apartmentId);
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
  String getOwnerName(Map<String, dynamic> apartment) {
    final owner = apartment['owner'];
    return "${owner['firstname']} ${owner['lastname']}";
  }

  String getOwnerMobile(Map<String, dynamic> apartment) {
    return apartment['owner']['mobile'];
  }

  List<String> getApartmentImageUrls(Map<String, dynamic> apartment) {
    final List<dynamic> images = apartment['images'] ?? [];
    return images.map((img) {
      return '${Apis.baseUrl}/storage/${img['image_path']}';
    }).toList();
  }

  String getProfileImageUrl(Map<String, dynamic> apartment) {
    final owner = apartment['owner'];
    if (owner['image'] == null || owner['image'].toString().isEmpty) return '';
    return '${Apis.baseUrl}/storage/${owner['image']}';
  }
}
