import 'dart:ui';

// Chỗ dưới này để test giao diện thôi

enum role { recruiter, candidate, admin }
final Color _color = Color(0xff071e26);

Color get color => _color;

List<String> jobLevel_key = ["intern", "fresher", "mid", "junior", "senior"];
List<String> jobLevel_value = ["Intern", "Fresher", "Mid", "Junior", "Senior"];

List<Map<String, String>> jobLevel = List.generate(
  jobLevel_key.length, (index) => {"key": jobLevel_key[index], "value": jobLevel_value[index]}
);
