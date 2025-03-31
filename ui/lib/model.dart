import 'dart:ui';

enum role { recruiter, candidate, admin }
final Color _color = Color(0xff071e26);

List<String> locations = [
  "124 Sương Nguyệt Ánh, Phường Bến Thành, Quận 1, Thành phố Hồ Chí Minh",
  "63/1 Bà Triệu, Thị trấn Hóc Môn, Huyện Hóc Môn, Thành phố Hồ Chí Minh",
  "48 Vạn Bảo, Phường Ngọc Khánh, Quận Ba Đình, Hà Nội",
  "V5-A10 Shophouse The Terra An Hưng, 102 Nguyễn Thanh Bình, Phường La Khê, Quận Hà Đông, Hà Nội",
  "224 Phạm Hùng, Xã Hòa Châu, Huyện Hòa Vang, Thành phố Đà Nẵng"
];


Color get color => _color;

List<String> jobType_key = ["full_time", "part_time", "remote", "free_lance"];
List<String> jobType_value = ["Toàn thời gian", "Bán thời gian", "Làm việc từ xa", "Làm việc tự do"];

List<Map<String, String>> jobType = List.generate(
  jobType_key.length, (index) => {"key": jobType_key[index], "value": jobType_value[index]},
);

List<String> jobLevel_key = ["intern", "fresher", "mid", "junior", "senior"];
List<String> jobLevel_value = ["Intern", "Fresher", "Mid", "Junior", "Senior"];

List<Map<String, String>> jobLevel = List.generate(
  jobLevel_key.length, (index) => {"key": jobLevel_key[index], "value": jobLevel_value[index]}
);
