import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import '../controllers/home_controller.dart';
import 'apartment_details_tenant_owner_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final HomeController controller = Get.find<HomeController>();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  final RxInt _selectedRooms = (-1).obs;
  final RxString _selectedSort = 'الأحدث'.obs;
  final RxList<Map<String, dynamic>> _filteredApartments =
      <Map<String, dynamic>>[].obs;
  final RxBool _isExpanded = F.obs;
  final RxBool _isLoading = false.obs;

  final List<int> _roomsOptions = [-1, 1, 2, 3, 4, 5];
  final List<String> _sortOptions = [
    'الأحدث',
    'الأقل سعراً',
    'الأعلى سعراً',
    'المساحة',
  ];

  @override
  void initState() {
    super.initState();
    _filteredApartments.assignAll(controller.featuredApartments);
  }

  void _applyFilters() {
    _isLoading.value = true;

    Future.delayed(const Duration(milliseconds: 300), () {
      List<Map<String, dynamic>> results = List.from(
        controller.featuredApartments,
      );

      // Search text filter
      if (_searchController.text.isNotEmpty) {
        results = results.where((apt) {
          final title = apt['title']?.toLowerCase() ?? '';
          final location = apt['location']?.toLowerCase() ?? '';
          final searchText = _searchController.text.toLowerCase();
          return title.contains(searchText) || location.contains(searchText);
        }).toList();
      }

      // City filter
      if (_cityController.text.isNotEmpty) {
        results = results.where((apt) {
          final location = apt['location']?.toLowerCase() ?? '';
          return location.contains(_cityController.text.toLowerCase());
        }).toList();
      }

      // Price range filter
      if (_minPriceController.text.isNotEmpty) {
        final min =
            double.tryParse(_minPriceController.text.replaceAll(',', '')) ?? 0;
        results = results.where((apt) {
          final priceStr =
              apt['price']?.split(' ')[0]?.replaceAll(',', '') ?? '0';
          final price = double.tryParse(priceStr) ?? 0;
          return price >= min;
        }).toList();
      }

      if (_maxPriceController.text.isNotEmpty) {
        final max =
            double.tryParse(_maxPriceController.text.replaceAll(',', '')) ??
            double.infinity;
        results = results.where((apt) {
          final priceStr =
              apt['price']?.split(' ')[0]?.replaceAll(',', '') ?? '0';
          final price = double.tryParse(priceStr) ?? 0;
          return price <= max;
        }).toList();
      }

      // Rooms filter
      if (_selectedRooms.value != -1) {
        results = results.where((apt) {
          final rooms = apt['rooms'];
          return rooms == _selectedRooms.value;
        }).toList();
      }

      // Sorting
      switch (_selectedSort.value) {
        case 'الأحدث':
          results.sort(
            (a, b) => (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''),
          );
          break;
        case 'الأقل سعراً':
          results.sort((a, b) {
            final priceA =
                double.tryParse(
                  a['price']?.split(' ')[0]?.replaceAll(',', '') ?? '0',
                ) ??
                0;
            final priceB =
                double.tryParse(
                  b['price']?.split(' ')[0]?.replaceAll(',', '') ?? '0',
                ) ??
                0;
            return priceA.compareTo(priceB);
          });
          break;
        case 'الأعلى سعراً':
          results.sort((a, b) {
            final priceA =
                double.tryParse(
                  a['price']?.split(' ')[0]?.replaceAll(',', '') ?? '0',
                ) ??
                0;
            final priceB =
                double.tryParse(
                  b['price']?.split(' ')[0]?.replaceAll(',', '') ?? '0',
                ) ??
                0;
            return priceB.compareTo(priceA);
          });
          break;
        case 'المساحة':
          results.sort((a, b) {
            final areaA = a['size'] ?? 0;
            final areaB = b['size'] ?? 0;
            return areaB.compareTo(areaA);
          });
          break;
      }

      _filteredApartments.assignAll(results);
      _isLoading.value = false;
      _isExpanded.value = F;
    });
  }

  void _clearFilters() {
    _searchController.clear();
    _cityController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    _selectedRooms.value = -1;
    _selectedSort.value = 'الأحدث';
    _filteredApartments.assignAll(controller.featuredApartments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'البحث عن شقة',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,

        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: const Icon(Icons.filter_alt_rounded, size: 22),
            ),
            onPressed: () => _isExpanded.value = !_isExpanded.value,
            tooltip: 'إظهار/إخفاء الفلاتر',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Section
          Obx(
            () => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _isExpanded.value ? null : 0,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'ابحث عن شقة أو مدينة...',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Colors.blue.shade700,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    color: Colors.grey.shade500,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _applyFilters();
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        onChanged: (_) => _applyFilters(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // City Filter
                    const Text(
                      'المدينة',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        hintText: 'أدخل اسم المدينة',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.location_city_rounded,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      onChanged: (_) => _applyFilters(),
                    ),
                    const SizedBox(height: 20),

                    // Price Range
                    const Text(
                      'نطاق السعر',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'من',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.attach_money_rounded,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            onChanged: (_) => _applyFilters(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _maxPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'إلى',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.attach_money_rounded,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            onChanged: (_) => _applyFilters(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Rooms Filter
                    const Text(
                      'عدد الغرف',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _roomsOptions.map((rooms) {
                          final label = rooms == -1 ? 'الكل' : '$rooms غرف';
                          final isSelected = _selectedRooms.value == rooms;
                          return ChoiceChip(
                            label: Text(
                              label,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: Colors.blue.shade700,
                            backgroundColor: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onSelected: (_) {
                              _selectedRooms.value = rooms;
                              _applyFilters();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sort By
                    const Text(
                      'ترتيب حسب',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _sortOptions.map((sort) {
                          final isSelected = _selectedSort.value == sort;
                          return ChoiceChip(
                            label: Text(
                              sort,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: Colors.blue.shade700,
                            backgroundColor: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onSelected: (_) {
                              _selectedSort.value = sort;
                              _applyFilters();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _clearFilters,
                            icon: const Icon(Icons.clear_all_rounded, size: 20),
                            label: const Text('مسح الكل'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _applyFilters,
                            icon: const Icon(Icons.search_rounded, size: 20),
                            label: const Text('تطبيق البحث'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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

          // Results Section
          Expanded(
            child: Obx(() {
              if (_isLoading.value) {
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
                        'جاري البحث...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (_filteredApartments.isEmpty) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'لا توجد نتائج',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'لم يتم العثور على شقق تطابق بحثك',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'جرب تغيير معايير البحث',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _clearFilters,
                            icon: const Icon(Icons.clear_all_rounded, size: 18),
                            label: const Text('إعادة تعيين البحث'),
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
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Results Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_filteredApartments.length} نتيجة',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          'مرتبة حسب: ${_selectedSort.value}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Apartments Grid
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.72,
                          ),
                      itemCount: _filteredApartments.length,
                      itemBuilder: (context, index) {
                        final apt = _filteredApartments[index];
                        return _buildApartmentCard(apt);
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildApartmentCard(Map<String, dynamic> apartment) {
    return Card(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openApartmentDetails(apartment),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Apartment Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Image.network(
                    apartment['image'] ?? '',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade100,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Icon(
                          Icons.home_rounded,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Apartment Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            apartment['title'] ?? 'شقة للإيجار',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
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
                                size: 12,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  apartment['location'] ?? 'لا يوجد عنوان',
                                  style: TextStyle(
                                    fontSize: 11,
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
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.hotel_rounded,
                                      size: 10,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${apartment['rooms']} غرف',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.blue.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.square_foot_rounded,
                                      size: 10,
                                      color: Colors.teal.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${apartment['size']} م²',
                                      style: TextStyle(
                                        fontSize: 10,
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

                      // Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            apartment['price'] ?? '0 ل.س',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: Colors.orange.shade600,
                              ),
                              const SizedBox(width: 2),
                              const Text('4.8', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openApartmentDetails(Map<String, dynamic> apartment) {
    Get.to(
      () => ApartmentDetailsTenantPage(
        apartment: {
          'id': apartment['id'],
          'title': apartment['title'],
          'location': apartment['location'],
          'price': apartment['price'],
          'rooms': apartment['rooms'],
          'bathrooms': apartment['bathrooms'],
          'size': apartment['size'],
          'description': apartment['description'] ?? 'لا يوجد وصف',
          'all_images': apartment['all_images'] ?? [],
          'owner_name': apartment['owner_name'] ?? 'مالك الشقة',
          'owner_mobile': apartment['owner_mobile'] ?? 'رقم غير متاح',
          'owner_image': apartment['owner_image'] ?? '',
        },
      ),
    );
  }
}
