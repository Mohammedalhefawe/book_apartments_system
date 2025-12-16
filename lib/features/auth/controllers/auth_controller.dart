import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:new_test_app/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:new_test_app/features/home_user/pages/home_wrapper_page.dart';

class AuthController extends GetxController {
  // Login
  var phone = ''.obs;
  var password = ''.obs;
  var passwordVisible = false.obs;

  // Register
  var firstName = ''.obs;
  var lastName = ''.obs;
  var birthday = Rxn<DateTime>();
  var role = 'صاحب شقة'.obs;
  var acceptTerms = false.obs;

  // Images
  var profileImage = Rxn<File>();
  var idImage = Rxn<File>();

  // Loading
  var isLoading = false.obs;

  // Validation
  var phoneError = RxString('');
  var passwordError = RxString('');
  var firstNameError = RxString('');
  var lastNameError = RxString('');
  var birthdayError = RxString('');

  final picker = ImagePicker();
  final List<String> roles = ['صاحب شقة', 'مستاجر'];

  void togglePasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }

  // Validate login
  bool validateLogin() {
    bool isValid = true;

    if (phone.value.isEmpty) {
      phoneError.value = 'رقم الهاتف مطلوب';
      isValid = false;
    } else if (!GetUtils.isPhoneNumber(phone.value)) {
      phoneError.value = 'رقم الهاتف غير صالح';
      isValid = false;
    } else {
      phoneError.value = '';
    }

    if (password.value.isEmpty) {
      passwordError.value = 'كلمة المرور مطلوبة';
      isValid = false;
    } else if (password.value.length < 6) {
      passwordError.value = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
      isValid = false;
    } else {
      passwordError.value = '';
    }

    return isValid;
  }

  // Validate register
  bool validateRegister() {
    bool isValid = true;

    if (firstName.value.isEmpty) {
      firstNameError.value = 'الاسم الأول مطلوب';
      isValid = false;
    } else {
      firstNameError.value = '';
    }

    if (lastName.value.isEmpty) {
      lastNameError.value = 'اسم العائلة مطلوب';
      isValid = false;
    } else {
      lastNameError.value = '';
    }

    if (birthday.value == null) {
      birthdayError.value = 'تاريخ الميلاد مطلوب';
      isValid = false;
    } else {
      birthdayError.value = '';
    }

    if (phone.value.isEmpty) {
      phoneError.value = 'رقم الهاتف مطلوب';
      isValid = false;
    } else if (!GetUtils.isPhoneNumber(phone.value)) {
      phoneError.value = 'رقم الهاتف غير صالح';
      isValid = false;
    } else {
      phoneError.value = '';
    }

    if (password.value.isEmpty) {
      passwordError.value = 'كلمة المرور مطلوبة';
      isValid = false;
    } else if (password.value.length < 6) {
      passwordError.value = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
      isValid = false;
    } else {
      passwordError.value = '';
    }

    return isValid;
  }

  // Image picker
  Future<void> pickImage(
    bool isProfile, {
    ImageSource source = ImageSource.gallery,
  }) async {
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      if (isProfile) {
        profileImage.value = File(picked.path);
      } else {
        idImage.value = File(picked.path);
      }
    }
  }

  // Birthday picker
  Future<void> pickBirthday(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      birthday.value = picked;
      birthdayError.value = '';
    }
  }

  // Login
  Future<void> login() async {
    // if (!validateLogin()) return;

    // isLoading.value = true;
    Get.offAll(() => HomeWrapper());

    // try {
    //   final response = await http.post(
    //     Uri.parse(Apis.login),
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode({'phone': phone.value, 'password': password.value}),
    //   );

    //   final data = jsonDecode(response.body);

    //   if (response.statusCode == 200) {
    //     Get.rawSnackbar(
    //       title: 'نجاح',
    //       message: data['message'] ?? 'تم تسجيل الدخول بنجاح',
    //       backgroundColor: Colors.green,
    //     );

    //         Get.offAll(() => HomeWrapper());

    //   } else {
    //     throw data['message'] ?? 'خطأ غير متوقع';
    //   }
    // } catch (e) {
    //   Get.rawSnackbar(
    //     title: 'خطأ',
    //     message: e.toString(),
    //     backgroundColor: Colors.red,
    //   );
    // } finally {
    //   isLoading.value = false;
    // }

  }
  //
  // Register
  Future<void> register() async {
    if (!validateRegister()) return;

    isLoading.value = true;

    try {
      final request = http.MultipartRequest('POST', Uri.parse(Apis.register));

      request.fields.addAll({
        'first_name': firstName.value,
        'last_name': lastName.value,
        'phone': phone.value,
        'password': password.value,
        'birthday': formattedBirthday ?? '',
        'role': role.value,
      });

      if (profileImage.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            profileImage.value!.path,
          ),
        );
      }

      if (idImage.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath('id_image', idImage.value!.path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.rawSnackbar(
          title: 'نجاح',
          message: data['message'] ?? 'تم إنشاء الحساب بنجاح',
          backgroundColor: Colors.green,
        );

        // Get.offAllNamed('/home');
      } else {
        throw data['message'] ?? 'فشل إنشاء الحساب';
      }
    } catch (e) {
      Get.rawSnackbar(
        title: 'خطأ',
        message: e.toString(),
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Format birthday
  String? get formattedBirthday {
    if (birthday.value == null) return null;
    return DateFormat('yyyy/MM/dd').format(birthday.value!);
  }

  // Clear data when switching pages
  void clearRegisterData() {
    firstName.value = '';
    lastName.value = '';
    birthday.value = null;
    role.value = 'صاحب شقة';
    profileImage.value = null;
    idImage.value = null;

    // Clear errors
    firstNameError.value = '';
    lastNameError.value = '';
    birthdayError.value = '';
    phoneError.value = '';
    passwordError.value = '';
  }

  // Clear login data
  void clearLoginData() {
    phone.value = '';
    password.value = '';
    passwordVisible.value = false;
    phoneError.value = '';
    passwordError.value = '';
  }
}
