import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReservationsController extends GetxController {
  var isLoading = false.obs;
  var currentTab = 'الكل'.obs;

  // Statistics
  var activeReservations = 0.obs;
  var pendingReservations = 0.obs;
  var completedReservations = 0.obs;

  // Sample data - replace with API call
  final List<Map<String, dynamic>> _allReservations = [
    {
      'id': 'RES-2024-001',
      'apartment': 'شقة في الرياض - حي الصحافة',
      'location': 'الرياض، حي الصحافة',
      'image': 'https://picsum.photos/200/200?random=1',
      'date': '15 مارس - 20 مارس 2024',
      'price': '١٢٥٠٠ ريال',
      'status': 'نشطة',
    },
    {
      'id': 'RES-2024-002',
      'apartment': 'فيلا في جدة - الكورنيش',
      'location': 'جدة، الكورنيش',
      'image': 'https://picsum.photos/200/200?random=2',
      'date': '1 أبريل - 10 أبريل 2024',
      'price': '٢٥٠٠٠ ريال',
      'status': 'معلقة',
    },
    {
      'id': 'RES-2024-003',
      'apartment': 'شقة في الخبر - حي الراكة',
      'location': 'الخبر، حي الراكة',
      'image': 'https://picsum.photos/200/200?random=3',
      'date': '10 فبراير - 15 فبراير 2024',
      'price': '٤٥٠٠ ريال',
      'status': 'منتهية',
    },
    {
      'id': 'RES-2024-004',
      'apartment': 'شقة في الدمام - حي الشاطئ',
      'location': 'الدمام، حي الشاطئ',
      'image': 'https://picsum.photos/200/200?random=4',
      'date': '5 يناير - 12 يناير 2024',
      'price': '٦٠٠٠ ريال',
      'status': 'ملغية',
    },
    {
      'id': 'RES-2024-005',
      'apartment': 'بيت في الطائف - حي الشرق',
      'location': 'الطائف، حي الشرق',
      'image': 'https://picsum.photos/200/200?random=5',
      'date': '25 مارس - 5 أبريل 2024',
      'price': '٨٠٠٠ ريال',
      'status': 'نشطة',
    },
  ];

  List<Map<String, dynamic>> get filteredReservations {
    if (currentTab.value == 'الكل') return _allReservations;
    return _allReservations
        .where((res) => res['status'] == currentTab.value)
        .toList();
  }

  List<Map<String, dynamic>> get reservations => _allReservations;

  @override
  void onInit() {
    super.onInit();
    fetchReservations();
  }

  Future<void> fetchReservations() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    _updateStatistics();
    isLoading.value = false;
  }

  void _updateStatistics() {
    activeReservations.value = _allReservations
        .where((res) => res['status'] == 'نشطة')
        .length;
    pendingReservations.value = _allReservations
        .where((res) => res['status'] == 'معلقة')
        .length;
    completedReservations.value = _allReservations
        .where((res) => res['status'] == 'منتهية')
        .length;
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

  void goToReservationDetails(String id) {
    Get.toNamed('/reservation-details/$id');
  }

  void cancelReservation(String id) {
    Get.defaultDialog(
      title: 'تأكيد الإلغاء',
      middleText: 'هل أنت متأكد من إلغاء هذا الحجز؟',
      textConfirm: 'نعم',
      textCancel: 'لا',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        Get.snackbar(
          'تم الإلغاء',
          'تم إلغاء الحجز بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
    );
  }
}
