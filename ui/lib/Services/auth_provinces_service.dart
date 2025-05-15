  import 'package:http/http.dart' as http;
  import 'package:ui/Models/Provinces.dart';
  import 'dart:convert';

  import '../Constants/api_constants.dart';
  import '../Models/ResponseModel.dart';

  class AuthProvincesService {
    final String _baseUrl = APIConstants.baseUrl;

    Future<ResponseModel> getProvinces() async {
      try {
        final response = await http.get(Uri.parse("$_baseUrl/auth/provinces"));

        if (response.statusCode == 200) {
          final List<dynamic> jsonData = json.decode(response.body);
          final List<cProvinces> provinceList =
          jsonData.map((item) => cProvinces.fromJson(item)).toList();

          return ResponseModel(
            success: true,
            message: "Thành công",
            messageList: ["Thành công"],
            data: provinceList,
          );
        } else {
          return ResponseModel(
            success: false,
            message: "Lỗi server: ${response.statusCode}",
            messageList: ["Lỗi server: ${response.statusCode}"],
          );
        }
      } catch (e) {
        return ResponseModel(
          success: false,
          message: "Lỗi kết nối: $e",
          messageList: ["Lỗi kết nối: $e"],
        );
      }
    }
  }
