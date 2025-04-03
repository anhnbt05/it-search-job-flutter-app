import 'dart:ui';

// Chỗ dưới này để test giao diện thôi

enum role { recruiter, candidate, admin }
final Color _color = Color(0xff071e26);

String branchName = "Thành phố Hồ Chí Minh";
String location = "124 Sương Nguyệt Ánh, Phường Bến Thành, Quận 1, Thành phố Hồ Chí Minh";

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

List<String> jobCategory_key = ['full_stack', 'front_end', 'back_end', 'mobile', 'software_engineer', 'devops', 'data_scientist', 'ai_engineer', 'game_developer', 'cyber_security', 'ui_ux_designer', 'qa_tester', 'embedded_engineer', 'other'];
List<String>  jobCategory_value = ['Lập trình Full-stack', 'Lập trình Font-end', 'Lập trình Back-end', 'Lập trình Mobile', 'Kỹ sư phần mềm', 'DevOps', 'Khoa học dữ liệu', 'Trí tuệ nhân tạo', 'Lập trình Game', 'An ninh mạng', 'Thiết kế UI/UX', 'Kiểm thử phần mềm', 'Lập trình nhúng', 'Khác'];

List<Map<String, String>> jobCategory = List.generate(
  jobCategory_key.length, (index) => {'key': jobCategory_key[index], 'value': jobCategory_value[index]});