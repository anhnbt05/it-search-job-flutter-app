import 'package:flutter/material.dart';

class ProfileCandidateView extends StatelessWidget {
  const ProfileCandidateView({super.key});

  @override
  Widget build(BuildContext context) {
    final candidate = {
      "FullName": "Lê Ngọc Anh",
      "Email": "lamduannhi0508@gmail.com",
      "PhoneNumber": "+84393873631",
      "AvatarUrl": "https://res.cloudinary.com/daiqcjyk9/image/upload/v1735465375/default_user_logo_b1f7pd.png",
      "Level": "Senior",
      "Bio": "Software developer with 3 years of experience in frontend development.",
      "Certifications": [
        "AWS Certified Developer",
        "Google Cloud Associate"
      ],
      "WorkExperiences": [
        {
          "Position": "Backend Developer",
          "CompanyName": "Công ty KMS Technology",
          "Location": "Phường 7, Quận Thủ Đức, TP. HCM",
          "JobType": "remote",
          "StartDate": "11/2024",
          "EndDate": "02/2025",
          "CompanyLogoUrl": "https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files/1744071950209-kms-tech.png",
          "Descriptions": [
            "Viết API cho hệ thống backend",
            "Dùng framework NestJS để tăng khả năng mở rộng cho hệ thống"
          ]
        },
        {
          "Position": "Frontend Developer",
          "CompanyName": "Google",
          "Location": "Mountain View, California",
          "JobType": "part_time",
          "StartDate": "06/2020",
          "EndDate": "12/2021",
          "CompanyLogoUrl": "https://logo.clearbit.com/google.com",
          "Descriptions": [
            "Xây dựng giao diện người dùng phản hồi bằng React",
            "Cải thiện hiệu năng lên 30%",
            "Hợp tác với các nhà thiết kế UX"
          ]
        }
      ]
    };

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(candidate['AvatarUrl'].toString()),
                  ),
                  const SizedBox(height: 12),
                  Text(candidate['FullName'].toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(candidate['Email'].toString(), style: const TextStyle(color: Colors.grey)),
                  Text(candidate['PhoneNumber'].toString(), style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Chip(label: Text(candidate['Level'].toString(), style: const TextStyle(color: Colors.white)), backgroundColor: Colors.blue),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _sectionTitle('Giới thiệu'),
            Text(candidate['Bio'].toString()),

            const SizedBox(height: 24),

            _sectionTitle('Chứng chỉ'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (candidate['Certifications'] as List).map((cert) {
                return Chip(
                  label: Text(cert),
                  avatar: const Icon(Icons.workspace_premium, size: 18),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            _sectionTitle('Kinh nghiệm làm việc'),
            ...((candidate['WorkExperiences'] as List).map((exp) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(exp['CompanyLogoUrl']),
                        radius: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(exp['Position'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(exp['CompanyName'], style: const TextStyle(color: Colors.grey)),
                            Text('${exp['StartDate']} - ${exp['EndDate']} • ${exp['JobType']}'),
                            Text(exp['Location'], style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 8),
                            ...List<Widget>.from((exp['Descriptions'] as List).map((desc) => Text("• $desc"))),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }).toList()),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
