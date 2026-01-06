import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:new_test_app/api.dart';
import 'package:new_test_app/constant.dart';
import 'package:new_test_app/features/home_tenant/pages/apartment_details_tenant_owner_page.dart';
import 'package:new_test_app/features/home_tenant/pages/search_page.dart';

class HomeController extends GetxController {
  var featuredApartments = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var hasMoreData = true.obs;

  int currentPage = 1;
  int lastPage = 1;

  @override
  void onInit() {
    super.onInit();
    fetchApartments(page: 1);
  }

  Future<void> fetchApartments({int page = 1, bool isRefresh = false}) async {
    if (page == 1 && !isRefresh) {
      isLoading.value = true;
    } else if (page > 1) {
      if (!hasMoreData.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
    }

    try {
      final url = page == 1
          ? Apis.approvedApartments
          : '${Apis.approvedApartments}?page=$page';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenUser',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        final List<dynamic> rawData = jsonResponse['data'];
        currentPage = jsonResponse['current_page'];
        lastPage = jsonResponse['last_page'];
        hasMoreData.value = currentPage < lastPage;

        final List<Map<String, dynamic>> mappedApartments = rawData.map((apt) {
          final List<String> imageUrls = (apt['images'] as List<dynamic>)
              .map<String>(
                (img) => '${Apis.baseUrl}/storage/${img['image_path']}',
              )
              .toList();

          final String mainImage = imageUrls.isNotEmpty
              ? imageUrls.first
              : 'https://via.placeholder.com/300x200?text=لا+توجد+صورة';

          return {
            'id': apt['id'],
            'title': apt['title'],
            'description': apt['description'],
            'price': '${apt['price']} ل.س',
            'image': mainImage,
            'rooms': apt['rooms'],
            'bathrooms': apt['bathrooms'],
            'size': apt['area'],
            'location': '${apt['city']} • ${apt['address']}',
            'status': apt['status'],
            'created_at': apt['created_at'],
            'all_images': imageUrls,
            'owner_name':
                '${apt['owner']['firstname']} ${apt['owner']['lastname']}',
            'owner_mobile': apt['owner']['mobile'],
            'owner_image': apt['owner']['image'] != null
                ? '${Apis.baseUrl}/storage/${apt['owner']['image']}'
                : '',
          };
        }).toList();

        if (page == 1) {
          featuredApartments.assignAll(mappedApartments);
        } else {
          featuredApartments.addAll(mappedApartments);
        }
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar('خطأ', error['message'] ?? 'فشل تحميل الشقق');
      }
    } catch (e) {
      Get.snackbar('خطأ في الاتصال', e.toString());
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Called on pull-to-refresh
  Future<void> onRefresh() async {
    currentPage = 1;
    hasMoreData.value = true;
    await fetchApartments(page: 1, isRefresh: true);
  }

  // Called when user scrolls to bottom
  Future<void> onLoadMore() async {
    if (hasMoreData.value && !isLoadingMore.value) {
      await fetchApartments(page: currentPage + 1);
    }
  }

  void goToSearch() {
    Get.to(() => const SearchPage());
  }

  void goToApartmentDetails(int id) {
    final apartment = featuredApartments.firstWhere(
      (apt) => apt['id'] == id,
      orElse: () => <String, dynamic>{},
    );

    if (apartment.isNotEmpty) {
      Get.to(() => ApartmentDetailsTenantPage(apartment: apartment));
    } else {
      Get.snackbar('خطأ', 'الشقة غير موجودة');
    }
  }
}
