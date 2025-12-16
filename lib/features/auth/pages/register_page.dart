import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../controllers/auth_controller.dart';
import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final AuthController controller = Get.put(AuthController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue.shade50, Colors.white, Colors.teal.shade50],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Bar Replacement
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'إنشاء حساب جديد',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Card
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'معلومات الحساب',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // First Name & Last Name Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'الاسم الأول',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      decoration: InputDecoration(
                                        hintText: 'محمد',
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                        errorText:
                                            controller
                                                .firstNameError
                                                .value
                                                .isEmpty
                                            ? null
                                            : controller.firstNameError.value,
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'الاسم الأول مطلوب';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        controller.firstName.value = value
                                            .trim();
                                        if (value.trim().isNotEmpty) {
                                          controller.firstNameError.value = '';
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'الاسم الأخير',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      decoration: InputDecoration(
                                        hintText: 'العلي',
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                        errorText:
                                            controller
                                                .lastNameError
                                                .value
                                                .isEmpty
                                            ? null
                                            : controller.lastNameError.value,
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'الاسم الأخير مطلوب';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        controller.lastName.value = value
                                            .trim();
                                        if (value.trim().isNotEmpty) {
                                          controller.lastNameError.value = '';
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Birthday
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تاريخ الميلاد',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Obx(
                                () => InkWell(
                                  onTap: () => controller.pickBirthday(context),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          controller
                                              .birthdayError
                                              .value
                                              .isNotEmpty
                                          ? Border.all(color: Colors.red)
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          controller.birthday.value == null
                                              ? 'اختر تاريخ الميلاد'
                                              : DateFormat('yyyy/MM/dd').format(
                                                  controller.birthday.value!,
                                                ),
                                          style: TextStyle(
                                            color:
                                                controller.birthday.value ==
                                                    null
                                                ? Colors.grey.shade500
                                                : Colors.grey.shade800,
                                          ),
                                        ),
                                        Icon(
                                          Icons.calendar_today,
                                          color: Colors.blue.shade700,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (controller.birthdayError.value.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    controller.birthdayError.value,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Role
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الدور',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Obx(
                                () => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: controller.role.value,
                                      isExpanded: true,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.grey.shade700,
                                      ),
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 16,
                                      ),
                                      items: controller.roles
                                          .map(
                                            (role) => DropdownMenuItem(
                                              value: role,
                                              child: Text(role),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) =>
                                          controller.role.value = value!,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Phone Number
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'رقم الهاتف',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                keyboardType: TextInputType.phone,
                                textDirection: TextDirection.ltr,
                                decoration: InputDecoration(
                                  hintText: '09xxxxxxxx',
                                  hintTextDirection: TextDirection.ltr,
                                  prefixStyle: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 0,
                                    minHeight: 0,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'رقم الهاتف مطلوب';
                                  }
                                  if (!GetUtils.isPhoneNumber(value.trim())) {
                                    return 'رقم الهاتف غير صالح';
                                  }
                                  return null;
                                },
                                onSaved: (value) =>
                                    controller.phone.value = value!.trim(),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Password
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'كلمة المرور',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Obx(
                                () => TextFormField(
                                  obscureText:
                                      !controller.passwordVisible.value,
                                  decoration: InputDecoration(
                                    hintText: 'أدخل كلمة المرور',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.passwordVisible.value
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey.shade600,
                                      ),
                                      onPressed: () {
                                        controller.togglePasswordVisibility();
                                      },
                                    ),
                                    errorText:
                                        controller.passwordError.value.isEmpty
                                        ? null
                                        : controller.passwordError.value,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'كلمة المرور مطلوبة';
                                    }
                                    if (value.length < 6) {
                                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    controller.password.value = value;
                                    if (value.isNotEmpty && value.length >= 6) {
                                      controller.passwordError.value = '';
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Profile Image Upload
                          Obx(() {
                            return _buildImageUploadSection(
                              title: 'صورة الملف الشخصي',
                              isRequired: true,
                              image: controller.profileImage.value,
                              onPickImage: () => controller.pickImage(true),
                            );
                          }),

                          const SizedBox(height: 20),

                          // ID Image Upload
                          Obx(() {
                            return _buildImageUploadSection(
                              title: 'صورة الهوية',
                              isRequired: true,
                              image: controller.idImage.value,
                              onPickImage: () => controller.pickImage(false),
                            );
                          }),

                          const SizedBox(height: 30),

                          // Register Button
                          Obx(
                            () => SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () {
                                        if (!_formKey.currentState!
                                            .validate()) {
                                          return;
                                        }

                                        // Additional custom validation
                                        if (controller.birthday.value == null) {
                                          controller.birthdayError.value =
                                              'تاريخ الميلاد مطلوب';
                                          return;
                                        }

                                        if (controller.profileImage.value ==
                                            null) {
                                          Get.rawSnackbar(
                                            title: 'خطأ',
                                            message: 'صورة الملف الشخصي مطلوبة',
                                            backgroundColor: Colors.red,
                                            borderRadius: 10,
                                            snackPosition: SnackPosition.TOP,
                                          );
                                          return;
                                        }

                                        if (controller.idImage.value == null) {
                                          Get.rawSnackbar(
                                            title: 'خطأ',
                                            message: 'صورة الهوية مطلوبة',
                                            backgroundColor: Colors.red,
                                            borderRadius: 10,
                                            snackPosition: SnackPosition.TOP,
                                          );
                                          return;
                                        }

                                        _formKey.currentState!.save();
                                        controller.register();
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'إنشاء الحساب',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Already have account
                          Center(
                            child: TextButton(
                              onPressed: () => Get.off(() => LoginPage()),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: Text.rich(
                                TextSpan(
                                  text: 'لديك حساب بالفعل؟ ',
                                  style: TextStyle(color: Colors.grey.shade600),
                                  children: [
                                    TextSpan(
                                      text: 'تسجيل الدخول',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection({
    required String title,
    required bool isRequired,
    required File? image,
    required VoidCallback onPickImage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            if (isRequired)
              const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),

        // Image Preview or Placeholder
        if (image != null)
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: FileImage(image),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: () {
                      if (title.contains('ملف')) {
                        controller.profileImage.value = null;
                      } else {
                        controller.idImage.value = null;
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
                // style: BorderStyle.,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 40,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(height: 8),
                Text(
                  'انقر لاختيار $title',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  'JPEG, PNG (الحد الأقصى 5MB)',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),

        // Upload Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickImage,
                icon: Icon(
                  Icons.photo_library,
                  size: 20,
                  color: Colors.blue.shade700,
                ),
                label: Text(
                  'من المكتبة',
                  style: TextStyle(color: Colors.blue.shade700),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Colors.blue.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Add camera functionality
                  if (title.contains('ملف')) {
                    controller.pickImage(true, source: ImageSource.camera);
                  } else {
                    controller.pickImage(false, source: ImageSource.camera);
                  }
                },
                icon: Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.teal.shade700,
                ),
                label: Text(
                  'الكاميرا',
                  style: TextStyle(color: Colors.teal.shade700),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Colors.teal.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
