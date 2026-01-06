import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:new_test_app/api.dart';
import 'package:new_test_app/constant.dart';
import 'package:new_test_app/features/home_owner/controllers/home_controller.dart'
    show HomeController;

class AddApartmentController extends GetxController {
  var title = ''.obs;
  var description = ''.obs;
  var city = 'Damascus'.obs; // default
  var address = ''.obs;
  var rooms = ''.obs;
  var bathrooms = ''.obs;
  var area = ''.obs;
  var price = ''.obs;

  var selectedImages = <File>[].obs;
  var isLoading = false.obs;

  final picker = ImagePicker();

  final List<String> cities = syrianCities;

  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      selectedImages.addAll(picked.map((x) => File(x.path)));
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  bool validate() {
    if (title.value.trim().isEmpty) {
      Get.snackbar('خطأ', 'العنوان مطلوب');
      return false;
    }
    if (description.value.trim().isEmpty) {
      Get.snackbar('خطأ', 'الوصف مطلوب');
      return false;
    }
    if (address.value.trim().isEmpty) {
      Get.snackbar('خطأ', 'العنوان مطلوب');
      return false;
    }
    if (rooms.value.trim().isEmpty || int.tryParse(rooms.value) == null) {
      Get.snackbar('خطأ', 'عدد الغرف غير صالح');
      return false;
    }
    if (bathrooms.value.trim().isEmpty ||
        int.tryParse(bathrooms.value) == null) {
      Get.snackbar('خطأ', 'عدد الحمامات غير صالح');
      return false;
    }
    if (area.value.trim().isEmpty || double.tryParse(area.value) == null) {
      Get.snackbar('خطأ', 'المساحة غير صالحة');
      return false;
    }
    if (price.value.trim().isEmpty || double.tryParse(price.value) == null) {
      Get.snackbar('خطأ', 'السعر غير صالح');
      return false;
    }
    if (selectedImages.isEmpty) {
      Get.snackbar('خطأ', 'يرجى إضافة صورة واحدة على الأقل');
      return false;
    }
    return true;
  }

  Future<void> submitApartment() async {
    if (!validate()) return;

    isLoading.value = true;

    try {
      var request = http.MultipartRequest('POST', Uri.parse(Apis.addApartment));

      request.headers.addAll({
        'Authorization': 'Bearer $tokenUser',
        'Accept': 'application/json',
      });

      request.fields.addAll({
        'title': title.value,
        'description': description.value,
        'city': city.value,
        'address': address.value,
        'rooms': rooms.value,
        'bathrooms': bathrooms.value,
        'area': area.value,
        'price': price.value,
      });

      // Add images as images[]
      for (var image in selectedImages) {
        request.files.add(
          await http.MultipartFile.fromPath('images[]', image.path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // Close page
        Get.snackbar(
          'نجاح',
          'تم إضافة الشقة بنجاح، في انتظار موافقة الإدارة',
          backgroundColor: Colors.green,
        );
        // Optional: Refresh home page
        Get.find<HomeController>().onRefresh();
      } else {
        final error = responseBody.isNotEmpty ? jsonDecode(responseBody) : {};
        throw error['message'] ?? 'فشل إضافة الشقة';
      }
    } catch (e) {
      Get.snackbar('خطأ', e.toString(), backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    title.value = '';
    description.value = '';
    address.value = '';
    rooms.value = '';
    bathrooms.value = '';
    area.value = '';
    price.value = '';
    selectedImages.clear();
  }
}
