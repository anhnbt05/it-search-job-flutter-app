import 'dart:ui';

enum role { recruiter, candidate, admin }
final Color _color = Color(0xff071e26);

List<String> locations = [
  "124 Sương Nguyệt Ánh, Phường Bến Thành, Quận 1, Thành phố Hồ Chí Minh",
  "63/1 Bà Triệu, Thị trấn Hóc Môn, Huyện Hóc Môn, Thành phố Hồ Chí Minh",
  "48 Vạn Bảo, Phường Ngọc Khánh, Quận Ba Đình, Hà Nội",
  "V5-A10 Shophouse The Terra An Hưng, 102 Nguyễn Thanh Bình, Phường La Khê, Quận Hà Đông, Hà Nội",
  "224 Phạm Hùng, Xã Hòa Châu, Huyện Hòa Vang, Thành phố Đà Nẵng"];
List<bool> selectedLocations = List.generate(5, (index) => false);

Color get color => _color;