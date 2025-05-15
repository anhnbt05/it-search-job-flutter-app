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
  cCategories? selectedCategory;

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
    final accessToken = APIConstants.accessToken;
    final categoryList = await categoryService.getCategory2(accessToken: accessToken);

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
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Bộ lọc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          DropdownButtonFormField<cProvinces>(
            decoration: const InputDecoration(
              labelText: 'Địa điểm',
              border: OutlineInputBorder(),
            ),
            value: selectedLocation,
            items: locations.map((loc) => DropdownMenuItem(
              value: loc,
              child: Text(loc.name),
            )).toList(),
            onChanged: (value) => setState(() => selectedLocation = value),
          ),

          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Danh mục', style: Theme.of(context).textTheme.labelLarge),
          ),
          Wrap(
            spacing: 8,
            children: categories.map((cat) {
              final selected = selectedCategory?.CategoryName == cat.CategoryName;
              return ChoiceChip(
                label: Text(cat.CategoryName ?? ''),
                selected: selected,
                onSelected: (val) {
                  setState(() {
                    selectedCategory = val ? cat : null;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedLocation = null;
                    selectedCategory = null;
                  });
                },
                child: const Text('Reset'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedLocation != null) {
                    await widget.viewModel.fetchJobsByLocation(selectedLocation!.id);
                  }

                  if (selectedCategory != null) {
                    await widget.viewModel.fetchJobsByCategory(selectedCategory!.CategoryName!);
                  }
                  else {
                    await widget.viewModel.fetchJobs();
                  }
                  Navigator.pop(context);
                },
                child: const Text('Apply Filters'),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}


