// controllers/owner_bookings_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:new_test_app/api.dart';
import 'package:new_test_app/constant.dart';

class OwnerBookingsController extends GetxController {
  var isLoading = false.obs;
  var currentTab = 'pending'.obs; // 'pending' or 'active'

  var pendingBookings = <Map<String, dynamic>>[].obs;
  var activeBookings = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllBookings();
  }

  Future<void> fetchAllBookings() async {
    await Future.wait([fetchPendingBookings(), fetchActiveBookings()]);
  }

  /// Fetch pending bookings (data is a normal List)
  Future<void> fetchPendingBookings() async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse(Apis.ownerPendingBookings),
        headers: {
          'Authorization': 'Bearer $tokenUser',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 1) {
          final List<dynamic> data = json['data']; // ← Normal list
          pendingBookings.assignAll(_mapBookings(data));
        }
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل جلب الطلبات المعلقة: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch active bookings (data is an object with string keys)
  Future<void> fetchActiveBookings() async {
    try {
      final response = await http.get(
        Uri.parse(Apis.ownerBookings),
        headers: {
          'Authorization': 'Bearer $tokenUser',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 1) {
          final dynamic rawData = json['data'];

          List<dynamic> dataList;

          if (rawData is List) {
            dataList = rawData;
          } else if (rawData is Map) {
            dataList = rawData.values
                .toList(); // ← Handles {"0": {...}, "2": {...}}
          } else {
            dataList = [];
          }

          activeBookings.assignAll(_mapBookings(dataList));
        }
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل جلب الحجوزات النشطة: $e');
    }
  }

  /// Universal mapping function
  List<Map<String, dynamic>> _mapBookings(List<dynamic> raw) {
    return raw.map((booking) {
      final apartment = booking['apartment'];
      final user = booking['user'];
      final images = (apartment['images'] as List<dynamic>?) ?? [];
      final mainImage = images.isNotEmpty
          ? '${Apis.baseUrl}/storage/apartments/${images[0]['image_path']}'
          : 'https://via.placeholder.com/200?text=لا+توجد+صورة';

      String statusArabic;
      switch (booking['status']) {
        case 'pending':
          statusArabic = 'معلقة';
          break;
        case 'active':
          statusArabic = 'نشطة';
          break;
        default:
          statusArabic = 'غير معروف';
      }

      return {
        'id': booking['id'],
        'booking_id': booking['id'],
        'apartment_title': apartment['title'],
        'apartment_location': '${apartment['city']} • ${apartment['address']}',
        'apartment_image': mainImage,
        'user_name': '${user['firstname']} ${user['lastname']}',
        'user_mobile': user['mobile'],
        'user_image': user['image'] != null
            ? '${Apis.baseUrl}/storage/${user['image']}'
            : '',
        'date': '${booking['start_date']} إلى ${booking['end_date']}',
        'price': '${apartment['price']} ل.س',
        'status': statusArabic,
        'raw_status': booking['status'],
      };
    }).toList();
  }

  List<Map<String, dynamic>> get currentBookings {
    return currentTab.value == 'pending' ? pendingBookings : activeBookings;
  }

  void changeTab(String tab) {
    currentTab.value = tab;
  }

  Color getStatusColor(String status) {
    return status == 'معلقة' ? Colors.orange : Colors.green;
  }

  Future<void> approveBooking(int bookingId) async {
    await _processBooking(bookingId, 'approve', 'تمت الموافقة على الحجز');
  }

  Future<void> rejectBooking(int bookingId) async {
    await _processBooking(bookingId, 'reject', 'تم رفض الحجز');
  }

  Future<void> _processBooking(
    int bookingId,
    String action,
    String successMsg,
  ) async {
    try {
      isLoading.value = true;
      final url = action == 'approve'
          ? Apis.ownerApproveBooking(bookingId)
          : Apis.ownerRejectBooking(bookingId);

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $tokenUser',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('نجاح', successMsg, backgroundColor: Colors.green);
        await fetchAllBookings(); // Refresh both tabs
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar('خطأ', error['message'] ?? 'فشلت العملية');
      }
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() async {
    await fetchAllBookings();
  }
}
