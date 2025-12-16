import 'package:get/get.dart';

class HomeController extends GetxController {
  // Example observable data for featured apartments
  var featuredApartments = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFeaturedApartments();
  }

  void fetchFeaturedApartments() async {
    isLoading.value = true;
    // TODO: Replace with real API call
    await Future.delayed(const Duration(seconds: 1));

    featuredApartments.assignAll([
      {
        'id': 1,
        'title': 'شقة فاخرة في الرياض',
        'price': '1500 ر.س / الشهر',
        'image': 'https://via.placeholder.com/300x200', // replace with real image
        'rooms': 3,
        'location': 'حي الملقا',
      },
      {
        'id': 2,
        'title': 'شقة عائلية في جدة',
        'price': '1200 ر.س / الشهر',
        'image': 'https://via.placeholder.com/300x200',
        'rooms': 4,
        'location': 'حي الروضة',
      },
      {
        'id': 3,
        'title': 'استوديو حديث في الدمام',
        'price': '800 ر.س / الشهر',
        'image': 'https://via.placeholder.com/300x200',
        'rooms': 1,
        'location': 'المنطقة الشرقية',
      },
    ]);

    isLoading.value = false;
  }

  void goToSearch() {
    // Get.toNamed('/search');
    Get.snackbar('بحث', 'سيتم إضافة صفحة البحث قريباً');
  }

  void goToApartmentDetails(int id) {
    // Get.toNamed('/apartment/$id');
    Get.snackbar('تفاصيل الشقة', 'معرف الشقة: $id');
  }
}