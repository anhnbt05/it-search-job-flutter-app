import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ui/Constants/api_constants.dart';

import '../../Models/Categories.dart';
import '../../Models/Provinces.dart';
import '../../Services/auth_provinces_service.dart';
import '../../Services/category_service.dart';
import '../../ViewModels/candidate/FindJobsViewModel.dart';
import 'package:provider/provider.dart';

class FilterBottomSheetView extends StatefulWidget {
  final FindJobsViewModel viewModel;

  const FilterBottomSheetView({super.key, required this.viewModel});

  @override
  State<FilterBottomSheetView> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheetView> {
  cProvinces? selectedLocation;
  List<cCategories?> selectedCategory = [];

  List<cProvinces> locations = [];
  List<cCategories> categories = [];

  bool isLoading = true;

  final authProvincesService = AuthProvincesService();
  final categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    loadFilterData();
  }

  Future<void> loadFilterData() async {
    final provinceResponse = await authProvincesService.getProvinces();
    final categoryList = await categoryService.getCategory2(context: context);

    final List<cProvinces> loadedLocations = [];
    final List<cCategories> loadedCategories = [];

    if (provinceResponse.success && provinceResponse.data != null) {
      loadedLocations.addAll(List<cProvinces>.from(provinceResponse.data));
    }

    if (categoryList != null) {
      try {
        loadedCategories.addAll(categoryList.map<cCategories>((e) {
          if (e is Map<String, dynamic>) {
            return cCategories(
              ID: e['ID'],
              CategoryName: e['CategoryName'],
            );
          } else {
            throw Exception('Invalid category format: $e');
          }
        }));
      } catch (e) {
        debugPrint("Error parsing category list: $e");
      }
    }

    setState(() {
      locations = loadedLocations;
      categories = loadedCategories;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 250,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery
              .of(context)
              .viewInsets
              .bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Bộ lọc công việc',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<cProvinces>(
                decoration: InputDecoration(
                  labelText: 'Chọn địa điểm',
                  labelStyle: const TextStyle(
                      color: Color(0xFF374151), fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(
                      Icons.location_on_outlined, color: Color(0xFF2563EB)),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                value: selectedLocation,
                items: locations.map((loc) {
                  return DropdownMenuItem(
                    value: loc,
                    child: Text(
                      loc.name,
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedLocation = value),
                dropdownColor: Colors.white,
                isExpanded: true,
              ),
      
              const SizedBox(height: 28),
      
              Text(
                'Chọn danh mục',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: categories.map((cat) {
                  final selected = selectedCategory.contains(cat);
                  return ChoiceChip(
                    label: Text(
                      cat.CategoryName ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? const Color(0xFF2563EB) : const Color(
                            0xFF6B7280),
                      ),
                    ),
                    selected: selected,
                    selectedColor: const Color(0xFFDBEAFE),
                    backgroundColor: const Color(0xFFF3F4F6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          selectedCategory.add(cat);
                        } else {
                          selectedCategory.remove(cat);
                        }
                      });
                    },
                    labelPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    pressElevation: 4,
                    shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                  );
                }).toList(),
              ),
      
              const SizedBox(height: 24),
      
              ElevatedButton.icon(
                onPressed: () async {
                  await widget.viewModel.fetchRecommendedJobs(context);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.star, color: Colors.white),
                label: const Text(
                  'Việc làm gợi ý',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  elevation: 4,
                ),
              ),
      
              const SizedBox(height: 24),
      
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        selectedLocation = null;
                        selectedCategory.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2563EB)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                    ),
                    child: const Text(
                      'Đặt lại',
                      style: TextStyle(
                          color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedLocation != null && selectedCategory.isNotEmpty)
                        {
                          await widget.viewModel.fetchJobsByBothLocationCategory(selectedLocation!.id, selectedCategory.map((e) => e!.CategoryName!).toList(),context);
                        }
                      else if (selectedLocation != null) {
                        await widget.viewModel.fetchJobsByLocation(
                            selectedLocation!.id,context);
                      } else if (selectedCategory.isNotEmpty) {
                        await widget.viewModel.fetchJobsByCategory(
                            selectedCategory.map((e) => e!.CategoryName!).toList(),context);
                      } else {
                        await widget.viewModel.fetchJobs(context);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                    ),
                    child: const Text(
                      'Áp dụng',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}



