// pages/favorites_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:new_test_app/api.dart';
import 'package:new_test_app/constant.dart';
import 'apartment_details_tenant_owner_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<Map<String, dynamic>>> _favoritesFuture;
  final Set<int> _removingFavorites = {};

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _fetchFavorites();
  }

  Future<void> _refreshFavorites() async {
    setState(() {
      _favoritesFuture = _fetchFavorites();
    });
  }

  Future<void> _removeFavorite(int apartmentId) async {
    setState(() {
      _removingFavorites.add(apartmentId);
    });

    try {
      final response = await http.delete(
        Uri.parse(Apis.removeFavorite(apartmentId)),
        headers: {'Authorization': 'Bearer $tokenUser'},
      );

      if (response.statusCode == 200) {
        await _refreshFavorites();
        Get.snackbar(
          'operation_completed'.tr,
          'removed_favorite'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'remove_favorite_error'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _removingFavorites.remove(apartmentId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Get.locale?.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'favorites'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Icon(Icons.refresh_rounded, size: 22),
            ),
            onPressed: _refreshFavorites,
            tooltip: 'refresh'.tr,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.blue,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        displacement: 40,
        onRefresh: _refreshFavorites,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _favoritesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'loading_favorites'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'loading_error'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'try_again'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _refreshFavorites,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text('retry'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'no_favorites'.tr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'add_to_favorites'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.search_rounded),
                          label: Text('browse_apartments'.tr),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final favorites = snapshot.data!;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: favorites.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final apt = favorites[index];
                final images = apt['images'] as List;
                final imageUrl = images.isNotEmpty
                    ? '${Apis.baseUrl}/storage/${images[0]['image_path']}'
                    : null;
                final owner = apt['owner'] as Map<String, dynamic>;

                return _buildFavoriteCard(apt, imageUrl, owner);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(
    Map<String, dynamic> apartment,
    String? imageUrl,
    Map<String, dynamic> owner,
  ) {
    final isRemoving = _removingFavorites.contains(apartment['id']);
    final isRTL = Get.locale?.languageCode == 'ar';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isRemoving
              ? null
              : () => _openApartmentDetails(apartment, owner),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Apartment Image
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey.shade100,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      );
                                    },
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade100,
                                  child: Center(
                                    child: Icon(
                                      Icons.home_rounded,
                                      size: 40,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.grey.shade100,
                                child: Center(
                                  child: Icon(
                                    Icons.home_rounded,
                                    size: 40,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Apartment Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            apartment['title'] ?? 'apartment_for_rent'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${apartment['city']} • ${apartment['address']}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue.shade100,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.hotel_rounded,
                                      size: 12,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${apartment['rooms']} ${'rooms'.tr}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.teal.shade100,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.square_foot_rounded,
                                      size: 12,
                                      color: Colors.teal.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${apartment['area']} ${'square_meter'.tr}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.teal.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Divider
                Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                const SizedBox(height: 16),

                // Price and Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'price'.tr,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${apartment['price']} ${'syrian_pound'.tr}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),

                    // Status and Remove Button
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: apartment['admin_status'] == 'approved'
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: apartment['admin_status'] == 'approved'
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                            ),
                          ),
                          child: Text(
                            apartment['admin_status'] == 'approved'
                                ? 'approved'.tr
                                : 'pending'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: apartment['admin_status'] == 'approved'
                                  ? Colors.green.shade800
                                  : Colors.orange.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Tooltip(
                          message: 'remove_from_favorites'.tr,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.shade50,
                            ),
                            child: IconButton(
                              onPressed: isRemoving
                                  ? null
                                  : () => _removeFavorite(apartment['id']),
                              icon: isRemoving
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.red.shade600,
                                            ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.favorite_rounded,
                                      color: Colors.red.shade600,
                                      size: 22,
                                    ),
                              splashRadius: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openApartmentDetails(
    Map<String, dynamic> apartment,
    Map<String, dynamic> owner,
  ) {
    final images = apartment['images'] as List;

    Get.to(
      () => ApartmentDetailsTenantPage(
        apartment: {
          'id': apartment['id'],
          'title': apartment['title'],
          'location': '${apartment['city']} • ${apartment['address']}',
          'price': '${apartment['price']} ${'syrian_pound'.tr}',
          'rooms': apartment['rooms'],
          'bathrooms': apartment['bathrooms'],
          'size': apartment['area'],
          'description': apartment['description'],
          'all_images': images
              .map((img) => '${Apis.baseUrl}/storage/${img['image_path']}')
              .toList(),
          'owner_name': '${owner['firstname']} ${owner['lastname']}',
          'owner_mobile': owner['mobile'],
          'owner_image': owner['image'] != null
              ? '${Apis.baseUrl}/storage/${owner['image']}'
              : '',
          'admin_status': apartment['admin_status'],
          'status': apartment['status'],
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchFavorites() async {
    try {
      final response = await http.get(
        Uri.parse(Apis.favorites),
        headers: {'Authorization': 'Bearer $tokenUser'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(json['data']);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load favorites');
    }
  }
}
