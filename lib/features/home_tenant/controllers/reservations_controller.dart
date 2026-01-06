import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:new_test_app/api.dart';
import 'package:new_test_app/constant.dart';

class ReservationsController extends GetxController {
  var isLoading = false.obs;
  var currentTab = 'الكل'.obs;

  // Statistics
  var activeReservations = 0.obs;
  var pendingReservations = 0.obs;
  var completedReservations = 0.obs;
  var cancelledReservations = 0.obs;

  var reservations = <Map<String, dynamic>>[].obs;

  final List<String> tabs = ['الكل', 'نشطة', 'معلقة', 'منتهية', 'ملغية'];

  @override
  void onInit() {
    super.onInit();
    fetchReservations();
  }

  Future<void> fetchReservations() async {
    isLoading.value = true;

    try {
      final response = await http.get(
        Uri.parse(Apis.myBookings),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenUser',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 1) {
          final List<dynamic> rawData = jsonResponse['data'];

          final List<Map<String, dynamic>> mappedReservations = rawData.map((
            booking,
          ) {
            final apartment = booking['apartment'];
            final images = apartment['images'] as List<dynamic>;
            final mainImage = images.isNotEmpty
                ? '${Apis.baseUrl}/storage/${images[0]['image_path']}'
                : 'https://via.placeholder.com/200?text=لا+توجد+صورة';

            String statusArabic;
            switch (booking['status']) {
              case 'active':
                statusArabic = 'نشطة';
                break;
              case 'pending':
                statusArabic = 'معلقة';
                break;
              case 'completed':
                statusArabic = 'منتهية';
                break;
              case 'cancelled':
                statusArabic = 'ملغية';
                break;
              default:
                statusArabic = 'غير معروف';
            }

            return {
              'id': 'RES-${booking['id']}',
              'booking_id': booking['id'],
              'apartment': apartment['title'],
              'location': '${apartment['city']} • ${apartment['address']}',
              'image': mainImage,
              'date': '${booking['start_date']} إلى ${booking['end_date']}',
              'price': '${apartment['price']} ل.س',
              'status': statusArabic,
              'raw_status': booking['status'],
            };
          }).toList();

          reservations.assignAll(mappedReservations);
          _updateStatistics();
        } else {
          Get.snackbar('خطأ', jsonResponse['message'] ?? 'فشل جلب الحجوزات');
        }
      } else {
        Get.snackbar('خطأ في الخادم', 'فشل الاتصال بالخادم');
      }
    } catch (e) {
      Get.snackbar('خطأ في الاتصال', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _updateStatistics() {
    activeReservations.value = reservations
        .where((r) => r['status'] == 'نشطة')
        .length;
    pendingReservations.value = reservations
        .where((r) => r['status'] == 'معلقة')
        .length;
    completedReservations.value = reservations
        .where((r) => r['status'] == 'منتهية')
        .length;
    cancelledReservations.value = reservations
        .where((r) => r['status'] == 'ملغية')
        .length;
  }

  List<Map<String, dynamic>> get filteredReservations {
    if (currentTab.value == 'الكل') return reservations;
    return reservations
        .where((res) => res['status'] == currentTab.value)
        .toList();
  }

  void changeTab(String tab) {
    currentTab.value = tab;
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'نشطة':
        return Colors.green;
      case 'معلقة':
        return Colors.orange;
      case 'منتهية':
        return Colors.blue;
      case 'ملغية':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> refreshReservations() async {
    await fetchReservations();
  }

  // Optional: Cancel booking (if your API supports it)
  Future<void> cancelReservation(int bookingId) async {
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
            await refreshReservations();
          } else {
            throw 'فشل الإلغاء';
          }
        } catch (e) {
          Get.snackbar('خطأ', 'فشل إلغاء الحجز', backgroundColor: Colors.red);
        }
      },
    );
  }

  // In ReservationsController class

  var isRating = false.obs;

  void showRateDialog(int bookingId) {
    final RxInt rating = 5.obs;
    final TextEditingController commentController = TextEditingController();
    final RxBool isSubmitting = false.obs;

    Get.dialog(
      Dialog(
        backgroundColor: Get.theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.star, size: 36, color: Colors.amber),
                ),

                const SizedBox(height: 16),

                Text(
                  'rateYourBooking'.tr,
                  style: Get.theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Get.theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 4),

                Text(
                  'shareYourExperience'.tr,
                  style: Get.theme.textTheme.bodyMedium?.copyWith(
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Star Rating
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final isSelected = index < rating.value;
                      return GestureDetector(
                        onTap: () => rating.value = index + 1,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            isSelected
                                ? Icons.star
                                : Icons.star_border_outlined,
                            size: 40,
                            color: Colors.amber,
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 12),

                // Rating Label
                Obx(
                  () => Text(
                    '${rating.value}.0 ${'stars'.tr}',
                    style: Get.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Get.theme.colorScheme.onSurface,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Comment Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'commentOptional'.tr,
                      style: Get.theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'writeYourExperience'.tr,
                        hintStyle: TextStyle(
                          color: Get.theme.colorScheme.onSurface.withOpacity(
                            0.5,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Get.theme.dividerColor.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Get.theme.dividerColor.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Get.theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Get.theme.cardColor,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      maxLines: 4,
                      minLines: 2,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Get.theme.colorScheme.onSurface
                              .withOpacity(0.7),
                          side: BorderSide(
                            color: Get.theme.dividerColor.withOpacity(0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('cancel'.tr),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: isSubmitting.value
                              ? null
                              : () => rateBooking(
                                  bookingId,
                                  rating.value,
                                  commentController.text.trim(),
                                  isSubmitting,
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 2,
                          ),
                          child: isSubmitting.value
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.send, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'submitRating'.tr,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> rateBooking(
    int bookingId,
    int rating,
    String comment,
    RxBool isSubmitting,
  ) async {
    isSubmitting.value = true;

    try {
      final response = await http.post(
        Uri.parse('${Apis.baseUrl}/api/bookings/$bookingId/rate'),
        headers: {
          'Authorization': 'Bearer $tokenUser',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'rating': rating.toString(),
          'comment': comment.isEmpty ? null : comment,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print(data);

        if (data['status'] == 1) {
          Get.back(); // Close dialog

          // Show success snackbar
          Get.snackbar(
            'thankYou'.tr,
            'ratingSubmittedSuccess'.tr,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
            icon: Icon(Icons.circle, color: Colors.green),
            shouldIconPulse: true,
            margin: const EdgeInsets.all(20),
            borderRadius: 12,
          );
        } else {
          throw Exception(data['message'] ?? 'ratingFailed'.tr);
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'ratingFailed'.tr);
      }
    } catch (e) {
      Get.back(); // Close dialog
      await Future.delayed(const Duration(milliseconds: 300));

      Get.snackbar(
        'error'.tr,
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        icon: Icon(Icons.circle_outlined, color: Colors.red),
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _handleUnauthorized() {
    Get.snackbar(
      'sessionExpired'.tr,
      'pleaseLoginAgain'.tr,
      backgroundColor: Colors.orange.shade50,
      colorText: Colors.orange,
      snackPosition: SnackPosition.BOTTOM,
    );

    Future.delayed(const Duration(seconds: 1), () {
      Get.offAllNamed('/login');
    });
  }
}
