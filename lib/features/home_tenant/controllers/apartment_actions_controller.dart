// controllers/apartment_actions_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:new_test_app/api.dart';
import 'package:new_test_app/constant.dart'; // for tokenUser

class ApartmentActionsController extends GetxController {
  var isFavorite = false.obs;
  var isBooking = false.obs;

  // Booking dates
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();

  // Check if apartment is already in favorites
  Future<void> checkFavoriteStatus(int apartmentId) async {
    try {
      final response = await http.get(
        Uri.parse(Apis.favorites),
        headers: {'Authorization': 'Bearer $tokenUser'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List favorites = json['data'];
        isFavorite.value = favorites.any((apt) => apt['id'] == apartmentId);
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> toggleFavorite(int apartmentId) async {
    final url = isFavorite.value
        ? Apis.removeFavorite(apartmentId)
        : Apis.addFavorite(apartmentId);

    final method = isFavorite.value ? http.delete : http.post;

    try {
      final response = await method(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $tokenUser',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'apartment_id': apartmentId}),
      );

      if (response.statusCode == 200) {
        isFavorite.value = !isFavorite.value;
        Get.snackbar(
          'تم',
          isFavorite.value ? 'تم إضافتها إلى المفضلة' : 'تم إزالتها من المفضلة',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشلت العملية');
    }
  }

  void showBookingDialog({required int apartmentId}) {
    startDate.value = null;
    endDate.value = null;

    Get.dialog(
      AlertDialog(
        title: const Text('حجز الشقة'),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('تاريخ البداية'),
                subtitle: Text(
                  startDate.value == null
                      ? 'اختر التاريخ'
                      : '${startDate.value!.day}/${startDate.value!.month}/${startDate.value!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: Get.context!,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) startDate.value = picked;
                },
              ),
              ListTile(
                title: const Text('تاريخ النهاية'),
                subtitle: Text(
                  endDate.value == null
                      ? 'اختر التاريخ'
                      : '${endDate.value!.day}/${endDate.value!.month}/${endDate.value!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: Get.context!,
                    initialDate:
                        startDate.value?.add(const Duration(days: 1)) ??
                        DateTime.now().add(const Duration(days: 2)),
                    firstDate:
                        startDate.value?.add(const Duration(days: 1)) ??
                        DateTime.now().add(const Duration(days: 1)),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) endDate.value = picked;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          Obx(
            () => ElevatedButton(
              onPressed: (startDate.value != null && endDate.value != null)
                  ? () => bookApartment(apartmentId: apartmentId)
                  : null,
              child: isBooking.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('تأكيد الحجز'),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> bookApartment({required int apartmentId}) async {
    if (startDate.value == null || endDate.value == null) return;

    isBooking.value = true;
    try {
      print({
        'apartment_id': apartmentId,
        'start_date': _formatDate(startDate.value!),
        'end_date': _formatDate(endDate.value!),
      });
      final response = await http.post(
        Uri.parse(Apis.bookApartment(apartmentId)),
        headers: {
          'Authorization': 'Bearer $tokenUser',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'apartment_id': apartmentId,
          'start_date': _formatDate(startDate.value!),
          'end_date': _formatDate(endDate.value!),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // Close dialog
        Get.snackbar(
          'نجاح',
          'تم إرسال طلب الحجز بنجاح',
          backgroundColor: Colors.green,
        );
      } else {
        print(response.body);
        throw 'فشل الحجز';
      }
    } catch (e) {
      Get.snackbar('خطأ', e.toString(), backgroundColor: Colors.red);
    } finally {
      isBooking.value = false;
    }
  }

  String _formatDate(DateTime date) => date.toIso8601String().split('T').first;
  Future<void> cancelBooking(int bookingId) async {
    Get.defaultDialog(
      title: 'تأكيد الإلغاء',
      middleText: 'هل أنت متأكد من إلغاء هذا الحجز؟',
      textConfirm: 'نعم، إلغاء',
      textCancel: 'تراجع',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        try {
          final response = await http.post(
            Uri.parse('${Apis.baseUrl}/api/bookings/$bookingId/cancel'),
            headers: {'Authorization': 'Bearer $tokenUser'},
          );

          if (response.statusCode == 200) {
            Get.snackbar(
              'تم الإلغاء',
              'تم إلغاء الحجز بنجاح',
              backgroundColor: Colors.green,
            );
            Get.back(); // Go back to refresh list
          } else {
            throw 'فشل الإلغاء';
          }
        } catch (e) {
          Get.snackbar('خطأ', 'فشل إلغاء الحجز', backgroundColor: Colors.red);
        }
      },
    );
  }
}
