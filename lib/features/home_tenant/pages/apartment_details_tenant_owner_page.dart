// pages/apartment_details_tenant_owner_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/apartment_actions_controller.dart';

class ApartmentDetailsTenantPage extends StatelessWidget {
  final Map<String, dynamic> apartment;

  const ApartmentDetailsTenantPage({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    final ApartmentActionsController controller = Get.put(
      ApartmentActionsController(),
    );
    controller.checkFavoriteStatus(apartment['id']);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageGallery(),
              collapseMode: CollapseMode.parallax,
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              Obx(
                () => IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.isFavorite.value
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: controller.isFavorite.value
                          ? Colors.red
                          : Colors.white,
                      size: 22,
                    ),
                  ),
                  onPressed: () => controller.toggleFavorite(apartment['id']),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              apartment['title'] ?? 'شقة للإيجار',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    apartment['location'] ?? 'لا يوجد عنوان',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade600,
                              Colors.green.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          apartment['price'] ?? '0 ل.س',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick Details
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildDetailChip(
                        icon: Icons.hotel_rounded,
                        text: '${apartment['rooms'] ?? '0'} غرف',
                        color: Colors.blue,
                      ),
                      _buildDetailChip(
                        icon: Icons.bathtub_rounded,
                        text: '${apartment['bathrooms'] ?? '0'} حمامات',
                        color: Colors.teal,
                      ),
                      _buildDetailChip(
                        icon: Icons.square_foot_rounded,
                        text: '${apartment['size'] ?? '0'} م²',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Description
                  const Text(
                    'الوصف',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        apartment['description'] ?? 'لا يوجد وصف',
                        style: const TextStyle(fontSize: 15, height: 1.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Owner Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'معلومات المالك',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundImage:
                                    apartment['owner_image']?.isNotEmpty == true
                                    ? NetworkImage(apartment['owner_image'])
                                    : const AssetImage(
                                            'assets/placeholder_user.png',
                                          )
                                          as ImageProvider,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    apartment['owner_name'] ?? 'مالك الشقة',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        apartment['owner_mobile'] ?? 'غير متاح',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Action Buttons
                  Column(
                    children: [
                      // Book Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            controller.showBookingDialog(
                              apartmentId: apartment['id'],
                            );
                          },
                          icon: const Icon(Icons.calendar_today_rounded),
                          label: Text(
                            'حجز الشقة',
                            style: const TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = apartment['all_images'] ?? [];
    if (images.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.home, size: 80)),
      );
    }

    return PageView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) => Image.network(
        images[index],
        fit: BoxFit.cover,
        loadingBuilder: (c, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator()),
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
