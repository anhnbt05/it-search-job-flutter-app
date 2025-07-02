import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/ViewModels/login/ProvincesViewModel.dart';
import 'package:ui/Views/login/verifyemail_page.dart';
import '../../Helpers/toastification.dart';
import '../../Models/CompanyLocations.dart';
import '../../Models/Companies.dart';
import '../../ViewModels/login/CompaniesViewModel.dart';
import '../../ViewModels/login/SignUpViewModel.dart';
import '../../ViewModels/login/VerifyEmailViewModel.dart';
import 'createbranch_page.dart';
import 'createcompany_page.dart';
import '../../Constants/color_constants.dart';

class RecruiterRegisterPage extends StatefulWidget {
  final String email;
  final String password;
  final String fullName;
  final String phone;

  const RecruiterRegisterPage({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
    Key? key,
  }) : super(key: key);

  @override
  State<RecruiterRegisterPage> createState() => _RecruiterRegisterPageState();
}

class _RecruiterRegisterPageState extends State<RecruiterRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<cCompanyLocations> locations = [];
  String? selectedCompanyId;
  String? selectedLocationId;
  List<cCompanies> filteredCompanies = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCompanies);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CompaniesViewModel>(context, listen: false).fetchCompanies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCompanies() {
    final vm = Provider.of<CompaniesViewModel>(context, listen: false);
    final query = _searchController.text.toLowerCase();

    setState(() {
      filteredCompanies =
          vm.companies.where((company) {
            return company.Name?.toLowerCase().contains(query) ?? false;
          }).toList();
    });
  }

  void fetchLocations(String companyId) async {
    final vm = Provider.of<CompaniesViewModel>(context, listen: false);
    await vm.fetchBranches(companyId);
    if (!mounted) return;
    setState(() {
      locations = vm.branches;
      selectedLocationId = null;
    });
  }

  void addCompany() async {
    final newCompany = await Navigator.push<cCompanies>(
      context,
      MaterialPageRoute(
        builder:
            (_) => MultiProvider(
              providers: [
                ChangeNotifierProvider.value(
                  value: Provider.of<CompaniesViewModel>(
                    context,
                    listen: false,
                  ),
                ),
                ChangeNotifierProvider.value(
                  value: Provider.of<ProvincesViewModel>(
                    context,
                    listen: false,
                  ),
                ),
              ],
              child: CreateCompanyPage(),
            ),
      ),
    );

    if (newCompany != null && newCompany.ID != null) {
      final companyVM = Provider.of<CompaniesViewModel>(context, listen: false);
      await companyVM.fetchCompanies();

      final newCompanyId = newCompany.ID!;
      final newBranch =
          newCompany.CompanyLocations?.isNotEmpty == true
              ? newCompany.CompanyLocations!.first
              : null;

      if (mounted) {
        setState(() {
          selectedCompanyId = newCompanyId;
          selectedLocationId = newBranch?.LocationID;
          locations = newBranch != null ? [newBranch] : [];
        });
      }
    }
  }

  void createBranch() async {
    if (selectedCompanyId == null) return;

    final newBranch = await Navigator.push<cCompanyLocations>(
      context,
      MaterialPageRoute(
        builder:
            (_) => Builder(
              builder:
                  (context) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider(
                        create: (_) => CompaniesViewModel(),
                      ),
                      ChangeNotifierProvider(
                        create: (_) => ProvincesViewModel(),
                      ),
                    ],
                    child: CreateBranchPage(companyId: selectedCompanyId!),
                  ),
            ),
      ),
    );

    if (newBranch != null) {
      if (!mounted) return;
      setState(() {
        if (!locations.any((loc) => loc.LocationID == newBranch.LocationID)) {
          locations.add(newBranch);
        }
        selectedLocationId = newBranch.LocationID;
      });
    }
  }

  Future<void> registerRecruiter() async {
    final signUpVM = Provider.of<SignUpViewModel>(context, listen: false);

    if (!_formKey.currentState!.validate() ||
        selectedCompanyId == null ||
        selectedLocationId == null) {
      showTopToastification(
        title: "Thiếu thông tin",
        content: "Vui lòng nhập đầy đủ thông tin",
        color: Colors.orange,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    final payload = {
      "Email": widget.email,
      "Password": widget.password,
      "FullName": widget.fullName,
      "PhoneNumber": widget.phone,
      "Role": "recruiter",
      "createRecruiterDto": {
        "Position": _positionController.text,
        "companyID": selectedCompanyId,
        "companyLocationID": selectedLocationId,
      },
    };

    final response = await signUpVM.register(payload);
    if (response.success) {
      showTopToastification(
        title: 'Thành công',
        content: response.message,
        color: Colors.green,
        icon: Icons.check_circle,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => ChangeNotifierProvider(
                create: (_) => VerifyEmailViewModel(),
                child: VerifyemailPage(email: widget.email),
              ),
        ),
      );
    } else {
      showTopToastification(
        title: 'Lỗi',
        content: response.message,
        color: Colors.red,
        icon: Icons.error,
      );
    }
  }

  Widget buildCompaniesList() {
    final vm = Provider.of<CompaniesViewModel>(context);
    final screenHeight = MediaQuery.of(context).size.height;

    if (vm.isLoading) return Center(child: CircularProgressIndicator());
    if (vm.errorMessage != null) return Text("Lỗi: ${vm.errorMessage}");

    final companiesToShow =
        _searchController.text.isEmpty ? vm.companies : filteredCompanies;

    return Container(
      height: screenHeight * 0.3,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child:
          companiesToShow.isEmpty
              ? Center(child: Text("Không tìm thấy công ty phù hợp"))
              : ListView.builder(
                itemCount: companiesToShow.length,
                itemBuilder: (context, index) {
                  final company = companiesToShow[index];
                  final id = company.ID ?? "";
                  return RadioListTile<String>(
                    value: id,
                    groupValue: selectedCompanyId,
                    title: Text(
                      company.Name ?? "Không tên",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: screenHeight * 0.018,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedCompanyId = value;
                      });
                      if (value != null) fetchLocations(value);
                    },
                  );
                },
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final signUpVM = Provider.of<SignUpViewModel>(context);
    final showBranchDropdown =
        selectedCompanyId != null && locations.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
            vertical: screenHeight * 0.05,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          ColorConstants.primaryColor,
                          ColorConstants.primaryColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Icon(Icons.business, size: 35, color: Colors.white),
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Đăng ký nhà tuyển dụng",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight * 0.035,
                      color: Colors.black87,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.015),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Vui lòng điền thông tin bên dưới để hoàn tất đăng ký",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey[700],
                      fontSize: screenHeight * 0.018,
                      height: 1.5,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.05),

                TextFormField(
                  controller: _positionController,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: screenHeight * 0.02,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: "VỊ TRÍ CÔNG VIỆC",
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey.shade600,
                      fontSize: screenHeight * 0.016,
                    ),
                    prefixIcon: Icon(Icons.work, color: Colors.grey.shade600),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: 20,
                    ),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? "Không được để trống"
                              : null,
                ),
                SizedBox(height: screenHeight * 0.04),

                TextFormField(
                  controller: _searchController,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: screenHeight * 0.02,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: "TÌM KIẾM CÔNG TY",
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey.shade600,
                      fontSize: screenHeight * 0.016,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _filterCompanies();
                              },
                            )
                            : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: 20,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),

                Text(
                  "CHỌN CÔNG TY",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: screenHeight * 0.018,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                buildCompaniesList(),
                SizedBox(height: screenHeight * 0.01),
                TextButton(
                  onPressed: addCompany,
                  child: Text(
                    "➕ Thêm công ty mới",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: ColorConstants.primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),

                if (showBranchDropdown) ...[
                  Text(
                    "CHỌN CHI NHÁNH",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: screenHeight * 0.018,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  DropdownButtonFormField<String>(
                    value: selectedLocationId,
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey.shade600,
                        fontSize: screenHeight * 0.016,
                      ),
                      prefixIcon: Icon(
                        Icons.location_city,
                        color: Colors.grey.shade600,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                        horizontal: 20,
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: screenHeight * 0.02,
                      color: Colors.black87,
                    ),
                    hint: Text(
                      "Chọn chi nhánh",
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    items:
                        locations.map((loc) {
                          final id = loc.ID ?? "";
                          return DropdownMenuItem<String>(
                            value: id,
                            child: Text(
                              loc.BranchName ?? "Không tên",
                              style: TextStyle(fontFamily: 'Poppins'),
                            ),
                          );
                        }).toList(),
                    onChanged:
                        (value) => setState(() => selectedLocationId = value),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  TextButton(
                    onPressed: createBranch,
                    child: Text(
                      "➕ Tạo chi nhánh mới",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                ],

                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.065,
                  child: ElevatedButton(
                    onPressed: signUpVM.isLoading ? null : registerRecruiter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child:
                        signUpVM.isLoading
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              "ĐĂNG KÝ",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontSize: screenHeight * 0.018,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Quay lại",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: screenHeight * 0.016,
                        color: ColorConstants.primaryColor,
                        fontWeight: FontWeight.w500,
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
}
